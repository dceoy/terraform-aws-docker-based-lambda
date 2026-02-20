"""A simple AWS Lambda function."""

import json
from typing import Any

from aws_lambda_powertools import Logger, Tracer  # type: ignore[reportMissingImports]

logger = Logger()  # type: ignore[reportUnknownVariableType]
tracer = Tracer()  # type: ignore[reportUnknownVariableType]


@logger.inject_lambda_context(log_event=True)  # type: ignore[reportUnknownMemberType]
@tracer.capture_lambda_handler  # type: ignore[reportUnknownMemberType, reportUntypedFunctionDecorator]
def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:  # noqa: ANN401
    """Lambda function handler.

    Args:
        event (dict): The event data passed to the Lambda function.
        context (Any): The context object containing information about the invocation,
            function, and execution environment.

    Returns:
        dict: A dictionary containing the status code and a JSON string with the
            message, event, and context information.
    """
    logger.info("event: %s", event)  # type: ignore[reportUnknownMemberType]
    logger.info("context: %s", vars(context))  # type: ignore[reportUnknownMemberType]
    body_dict = {
        "message": "Hello World!",
        "event": event,
        "context_invoked_function_arn": context.invoked_function_arn,
        "context_log_stream_name": context.log_stream_name,
        "context_log_group_name": context.log_group_name,
        "context_aws_request_id": context.aws_request_id,
        "context_memory_limit_in_mb": context.memory_limit_in_mb,
    }
    logger.info("body_dict: %s", body_dict)  # type: ignore[reportUnknownMemberType]
    return {"statusCode": 200, "body": json.dumps(body_dict)}
