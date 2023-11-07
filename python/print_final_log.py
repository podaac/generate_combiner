#!/app/env/bin/python3
"""Logs final log statement.

Logs a final log statement from a TXT file used by the combiner to track data
on current state for Cloud Metrics.
"""

# Standard imports
import logging
import os
import pathlib
import sys

def print_final_log():
    """Print final log message."""
    
    logger = get_logger()
    
    # Open file used to track data
    log_file = pathlib.Path(os.getenv('FINAL_LOG_MESSAGE'))
    with open(log_file) as fh:
        log_data = fh.read().splitlines()

    # Organize file data into a string
    execution_data = ""
    processed = []
    created = []
    quarantined = []
    wait = []
    totals = ""
    for line in log_data:
        if "execution_data" in line: execution_data += line.split("execution_data: ")[-1]
        if "processed" in line: processed.append(line.split("processed: ")[-1])
        if "created" in line and "number_combined_created" not in line: created.append(line.split("created: ")[-1])
        if "quarantined" in line: quarantined.append(line.split("quarantined: ")[-1])
        if "sst_wait" in line: wait.append(line.split("sst_wait: ")[-1])
        if "totals" in line: totals += line.split("totals: ")[-1]
    
    final_log_message = "- "
    if execution_data: final_log_message += f"{execution_data} - "
    if totals: final_log_message += f"{totals} - "
    if len(processed) > 0: final_log_message += f"processed: {', '.join(processed)} - "
    if len(created) > 0: final_log_message += f"created: {', '.join(created)} - "
    if len(quarantined) > 0: final_log_message += f"quarantined: {', '.join(quarantined)} - "
    if len(wait) > 0: final_log_message += f"sst_wait_file: {', '.join(wait)} - "
    
    # Print final log message and remove temp log file
    logger.info(final_log_message)
    log_file.unlink()
    
def get_logger():
    """Return a formatted logger object."""
    
    # Create a Logger object and set log level
    logger = logging.getLogger(__name__)
    
    if not logger.hasHandlers():
        logger.setLevel(logging.DEBUG)

        # Create a handler to console and set level
        console_handler = logging.StreamHandler(sys.stdout)    # Log to standard out to support IDL SPAWN

        # Create a formatter and add it to the handler
        console_format = logging.Formatter("%(module)s - %(levelname)s : %(message)s")
        console_handler.setFormatter(console_format)

        # Add handlers to logger
        logger.addHandler(console_handler)

    # Return logger
    return logger
    
if __name__ == "__main__":
        print_final_log()