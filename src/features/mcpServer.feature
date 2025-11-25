Feature: Connect MCP servers on Obot

    Background: Navigate to Obot
        Given I setup context for assertion
        When User navigates to the Obot main login page
        Then User opens chat Obot
        And User creates a new Project with no existing connections

    Scenario Outline: Validate <ServerName> MCP Server sequential prompts on Obot
        When User opens the MCP connector page
        And User selects "<ConnectionName>" MCP server
        And User selects "Connect To Server" button
        And User connects to the "<ConnectionName>" MCP server
        When User sends prompts to Obot AI chat for "<PromptName>" MCP server
        Then All prompt results should be validated and a report generated for the selected "<ReportName>" MCP server

        Examples:
            | ServerName                  | ConnectionName                     | PromptName       | ReportName       |
            | wordpress                   | WordPress                          | WordPress        | WordPress        |
            | gitlab                      | GitLab                             | GitLab           | GitLab           |
            | bigquery                    | BigQuery                           | BigQuery Toolbox | BigQuery Toolbox |
            # | datadog                     | Datadog                            | Datadog          | Datadog          |
            | databricks_uc_functions     | Databricks Unity Catalog Functions | Databrick Unity  | Databrick Unity  |
            | databricks_genie            | Databricks Genie Space             | Databrick Genie  | Databrick Genie  |
            | databricks_vector_search    | Databricks Vector Space            | Databrick Vector | Databrick Vector |
            | brave_search                | Brave Search                       | Brave Search     | Brave Search     |
            | chroma                      | Chroma Cloud                       | Chroma Cloud     | Chroma Cloud     |
            | firecrawl                   | Firecrawl                          | Firecrawl        | Firecrawl        |
            | gitmcp                      | GitMCP                             | GitMCP           | GitMCP           |
            | redis                       | Redis                              | Redis            | Redis            |
            # | postman                     | Postman                            | Postman          | Postman          |
            | tavily_search               | Tavily Search                      | Tavily Search    | Tavily Search    |
            | exa_search                  | Exa Search                         | Exa Search       | Exa Search       |
            | deepwiki                    | DeepWiki                           | DeepWiki         | DeepWiki         |
            | aws                         | AWS API                            | AWS API          | AWS API          |
            | aws_cdk                     | AWS CDK                            | AWS CDK          | AWS CDK          |
            | aws_documentation           | AWS Documentation                  | AWS Documentation| AWS Documentation|
            | aws_eks                     | AWS EKS                            | AWS EKS          | AWS EKS          |
            | aws_kendra                  | AWS Kendra                         | AWS Kendra       | AWS Kendra       |
            | aws_knowledge               | AWS Knowledge                      | AWS Knowledge    | AWS Knowledge    |
            | aws_redshift                | AWS Redshift                       | AWS Redshift     | AWS Redshift     |