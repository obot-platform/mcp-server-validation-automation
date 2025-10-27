Feature: Connecte MCP server on Obot

    Background: Navigate to Obot
        Given I setup context for assertion
        When User navigates the Obot main login page
        Then User open chat Obot

    Scenario: Validate Wordpress sequential prompts on Obot
        When User open MCP connector page
        And User select "WordPress" MCP server
        And User select "Connect To Server" button
        And User connect to the WordPress1 MCP server 
        When User sends prompts to Obot AI chat for "Wordpress" MCP server
        Then All prompts results should be validated and report generated for selected "Wordpress" MCP Server

    Scenario: Validate GitLab sequential prompts on Obot 
        When User open MCP connector page
        And User select "GitLab" MCP server
        And User select "Connect To Server" button
        And User connect to the GitLab MCP server
        When User sends prompts to Obot AI chat for "Gitlab" MCP server
        Then All prompts results should be validated and report generated for selected "Gitlab" MCP Server