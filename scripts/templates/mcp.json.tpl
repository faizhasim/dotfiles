{
  "mcpServers": {
    "Atlassian": {
      "url": "op://Private/mcp-info/seek-mcp-atlassian-url"
    },
    "Backstage": {
      "url": "op://Private/mcp-info/seek-mcp-backstage-url"
    },
    "GitHub": {
      "url": "op://Private/mcp-info/seek-mcp-github-url"
    },
    "Glean": {
      "url": "op://Private/mcp-info/seek-mcp-glean-url"
    },
    "Buildkite": {
      "url": "op://Private/mcp-info/buildkite-mcp-url",
      "headers": {
        "X-Buildkite-Toolsets": "op://Private/mcp-info/buildkite-mcp-toolsets"
      }
    },
    "Datadog": {
      "url": "op://Private/mcp-info/datadog-mcp-url",
      "headers": {
        "DD-SITE": "op://Private/mcp-info/datadog-mcp-site",
        "DD-API-KEY": "op://Private/mcp-info/datadog-mcp-dd-api-key",
        "DD-APPLICATION-KEY": "op://Private/mcp-info/datadog-mcp-dd-application-key"
      }
    }
  }
}
