Feature: Connect MCP servers on Obot

    Background: Navigate to Obot
        Given I setup context for assertion
        When User navigates to the Obot main login page
        Then User opens chat Obot
        And User creates a new Project with no existing connections

    Scenario Outline: Validate <ServerName> sequential prompts on Obot
        When User opens the MCP connector page
        And User selects "<ServerName>" MCP server
        And User selects "Connect To Server" button
        And User connects to the "<ConnectionName>" MCP server
        When User sends prompts to Obot AI chat for "<PromptName>" MCP server
        Then All prompt results should be validated and a report generated for the selected "<ReportName>" MCP server

        Examples:
            | ServerName                         | ConnectionName                     | PromptName       | ReportName       |
            | WordPress                          | WordPress                          | WordPress        | WordPress        |
            | GitLab                             | GitLab                             | GitLab           | GitLab           |
            | BigQuery Toolbox                   | BigQuery                           | BigQuery Toolbox | BigQuery Toolbox |
            # | Datadog                            | Datadog                            | Datadog          | Datadog          |
            | Databricks Unity Catalog Functions | Databricks Unity Catalog Functions | Databrick Unity  | Databrick Unity  |
            | Databricks Genie Spaces            | Databricks Genie Space             | Databrick Genie  | Databrick Genie  |
            | Databricks Vector Search           | Databricks Vector Space            | Databrick Vector | Databrick Vector |
            | Brave Search                       | Brave Search                       | Brave Search     | Brave Search     |
            | Chroma Cloud                       | Chroma Cloud                       | Chroma Cloud     | Chroma Cloud     |
            | Firecrawl                          | Firecrawl                          | Firecrawl        | Firecrawl        |
            | GitMCP                             | GitMCP                             | GitMCP           | GitMCP           |
            | Redis                              | Redis                              | Redis            | Redis            |
            # | Postman                            | Postman                            | Postman          | Postman          |
            | Tavily Search                      | Tavily Search                      | Tavily Search    | Tavily Search    |
            | Exa Search                         | Exa Search                         | Exa Search       | Exa Search       |
            | DeepWiki                           | DeepWiki                           | DeepWiki         | DeepWiki         |   
