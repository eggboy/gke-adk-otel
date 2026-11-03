"""Multimodal demo agent: text chat plus image understanding, with one tiny tool."""

from datetime import UTC, datetime

from google.adk.agents import Agent


def get_current_time() -> dict[str, str]:
    """Return the current UTC time.

    Returns:
        A dict with the current UTC time in ISO 8601 format.
    """
    return {"utc_time": datetime.now(UTC).isoformat()}


root_agent = Agent(
    name="demo_agent",
    model="gemini-2.5-flash",
    description="Multimodal demo agent for the GKE Managed OpenTelemetry GA demo.",
    instruction=(
        "You are a friendly demo assistant. Answer questions concisely. "
        "If the user attaches an image, describe what you see in it in detail. "
        "Use the get_current_time tool whenever asked about the current time or date."
    ),
    tools=[get_current_time],
)
