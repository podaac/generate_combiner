#!/app/env/bin/python3
"""Logs and sends email notification when combiner encounters an error.

Logs the error message.
Pusblishes error message to SNS Topic.
"""

# Standard imports
import argparse
import datetime
import time
import logging
import os
import sys

# Third-party imports
import boto3
import botocore

# Constants
TOPIC_STRING = "batch-job-failure"

def notify(sigevent_type, sigevent_description, sigevent_data):
    """Handles error events."""
    
    logger = get_logger()
    log_event(sigevent_type, sigevent_description, sigevent_data, logger)
    if sigevent_type == "ERROR": publish_event(sigevent_type, sigevent_description, sigevent_data, logger)
    sys.exit(0)
    
def get_logger():
    """Return a formatted logger object."""
    
    # Create a Logger object and set log level
    logger = logging.getLogger(__name__)
    
    if not logger.hasHandlers():
        logger.setLevel(logging.DEBUG)

        # Create a handler to console and set level
        console_handler = logging.StreamHandler(sys.stdout)    # Log to standard out to support IDL SPAWN

        # Create a formatter and add it to the handler
        console_format = logging.Formatter("%(asctime)s - %(module)s - %(levelname)s : %(message)s")
        console_handler.setFormatter(console_format)

        # Add handlers to logger
        logger.addHandler(console_handler)

    # Return logger
    return logger

def log_event(sigevent_type, sigevent_description, sigevent_data, logger):
    """Log event details in CloudWatch."""
    
    # Log to batch log stream
    log_to_job_stream(sigevent_type, sigevent_description, sigevent_data, logger)
    
    # Log to combiner error log stream
    logs = boto3.client("logs")
    try:
        # Locate log group
        describe_group_response = logs.describe_log_groups(
            logGroupNamePattern="combiner-errors"
        )
        log_group_name = describe_group_response["logGroups"][0]["logGroupName"]
        
        # Find or create log stream - New creation happens every hour
        log_stream_name = f"{os.getenv('AWS_BATCH_JQ_NAME')}-combiner-job-error-{datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H')}0000"
        describe_stream_response = logs.describe_log_streams(
            logGroupName=log_group_name,
            logStreamNamePrefix=log_stream_name
        )
        if len(describe_stream_response["logStreams"]) == 0:       
            create_response = logs.create_log_stream(
                logGroupName=log_group_name,
                logStreamName=log_stream_name
            )
        else:
            log_stream_name=describe_stream_response["logStreams"][0]["logStreamName"]
        
        # Send logs
        log_events = [
            {
                "timestamp": int(time.time() * 1000),
                "message": "==================================================="
            },
            {
                "timestamp": int(time.time() * 1000),
                "message": "Combiner job ERROR encountered."
            },
            {
                "timestamp": int(time.time() * 1000),
                "message": f"Job Identifier: {os.getenv('AWS_BATCH_JOB_ID')}"
            },
            {
                "timestamp": int(time.time() * 1000),
                "message": f"Job Queue: {os.getenv('AWS_BATCH_JQ_NAME')}"
            },
            {
                "timestamp": int(time.time() * 1000),
                "message": f"Error type: {sigevent_type}"
            },
            {
                "timestamp": int(time.time() * 1000),
                "message": f"Error description: {sigevent_description}"
            }
        ]
        if sigevent_data != "": log_events.append({
            "timestamp": int(time.time() * 1000),
            "message": f"Error data: {sigevent_data}"
        })
        put_response = logs.put_log_events(
            logGroupName=log_group_name,
            logStreamName=log_stream_name,
            logEvents=log_events
        )
        logger.info(f"Logged error message to: {log_group_name}{log_stream_name}")    
    except botocore.exceptions.ClientError as e:
        logger.error("Failed to log to CloudWatch.")
        logger.error(f"Error - {e}")
        sys.exit(1)
        
def log_to_job_stream(sigevent_type, sigevent_description, sigevent_data, logger):
    """Log event details to current Batch job log stream."""
    
    if sigevent_type == "INFO":
        logger.info(f"Job Identifier: {os.getenv('AWS_BATCH_JOB_ID')}")
        logger.info(f"Job Queue: {os.getenv('AWS_BATCH_JQ_NAME')}")
        logger.info(f"Error type: {sigevent_type}")
        logger.info(f"Error description: {sigevent_description}")
        if sigevent_data != "": logger.info(f"Error data: {sigevent_data}")
        
    if sigevent_type == "WARN":
        logger.warning(f"Job Identifier: {os.getenv('AWS_BATCH_JOB_ID')}")
        logger.warning(f"Job Queue: {os.getenv('AWS_BATCH_JQ_NAME')}")
        logger.warning(f"Error type: {sigevent_type}")
        logger.warning(f"Error description: {sigevent_description}")
        if sigevent_data != "": logger.warning(f"Error data: {sigevent_data}")
    
    if sigevent_type == "ERROR":    
        logger.error(f"Job Identifier: {os.getenv('AWS_BATCH_JOB_ID')}")
        logger.error(f"Job Queue: {os.getenv('AWS_BATCH_JQ_NAME')}")
        logger.error(f"Error type: {sigevent_type}")
        logger.error(f"Error description: {sigevent_description}")
        if sigevent_data != "": logger.error(f"Error data: {sigevent_data}")
    
def publish_event(sigevent_type, sigevent_description, sigevent_data, logger):
    """Publish event to SNS Topic."""
    
    sns = boto3.client("sns")
    
    # Get topic ARN
    try:
        topics = sns.list_topics()
    except botocore.exceptions.ClientError as e:
        logger.error("Failed to list SNS Topics.")
        logger.error(f"Error - {e}")
        sys.exit(1)
    for topic in topics["Topics"]:
        if TOPIC_STRING in topic["TopicArn"]:
            topic_arn = topic["TopicArn"]
            
    # Publish to topic
    subject = f"Generate Batch Job Failure: {os.getenv('SIGEVENT_SOURCE')}"
    message = f"Generate AWS Batch combiner job has encountered an error.\n" \
        + f"Job Identifier: {os.getenv('AWS_BATCH_JOB_ID')}.\n" \
        + f"Job Queue: {os.getenv('AWS_BATCH_JQ_NAME')}.\n" \
        + f"Error type: {sigevent_type}.\n" \
        + f"Error description: {sigevent_description}\n"
    if sigevent_data != "": message += f"Error data: {sigevent_data}"
    try:
        response = sns.publish(
            TopicArn = topic_arn,
            Message = message,
            Subject = subject
        )
    except botocore.exceptions.ClientError as e:
        logger.error(f"Failed to publish to SNS Topic: {topic_arn}.")
        logger.error(f"Error - {e}")
        sys.exit(1)
    
    logger.info(f"Message published to SNS Topic: {topic_arn}.")
    
def create_args():
    """Create and return argparser with arguments."""

    arg_parser = argparse.ArgumentParser(description="Update Confluence SoS priors.")
    arg_parser.add_argument("-t",
                            "--type",
                            type=str,
                            choices=["INFO", "WARN", "ERROR"],
                            help="Type of event: INFO, WARN, ERROR.")
    arg_parser.add_argument("-d",
                            "--description",
                            type=str,
                            help="Description of event.")
    arg_parser.add_argument("-i",
                            "--data",
                            type=str,
                            help="Extra details on the event.")
    return arg_parser
    
if __name__ == "__main__":
    
    arg_parser = create_args()
    args = arg_parser.parse_args()
    notify(args.type, args.description, args.data)