import { When, Then, Given } from "@wdio/cucumber-framework";
import Selectors from "../core/selectors";
import {
  clickToElement,
  isElementDisplayed,
  slowInputFilling,
} from "../core/func";
import { LONG_PAUSE, SHORT_PAUSE } from "../core/timeouts";
import {
  aggregateToolResponses,
  saveMCPReport,
  sendPromptValidateAndCollect,
} from "../core/mcpFunc";
import path from "path";
import { promises as fs } from "fs";

Given(/^User navigates the Obot main login page$/, async () => {
  const url = process.env.OBOT_URL;
  await browser.url(url);
});

Then(/^User open chat Obot$/, async () => {
  await clickToElement(Selectors.MCP.navigationbtn);
  await clickToElement(Selectors.MCP.clickChatObot);
});

When(/^User open MCP connector page$/, async () => {
  await clickToElement(Selectors.MCP.connectorbtn);
});

Then(/^User select "([^"]*)" MCP server$/, async (MCPServer) => {
  await slowInputFilling(Selectors.MCP.mcpSearchInput, MCPServer);
  await isElementDisplayed(
    Selectors.MCP.selectMCPServer(MCPServer),
    LONG_PAUSE,
  );
  // Wait until matching elements appear
  const allServers = await $$(Selectors.MCP.selectMCPServer(MCPServer));
  if ((await allServers.length) === 0)
    throw new Error(`No MCP server found matching: ${MCPServer}`);

  // Click the last one
  const lastServer = allServers[(await allServers.length) - 1];
  await lastServer.waitForDisplayed({ timeout: LONG_PAUSE });
  await lastServer.click();

  await browser.pause(SHORT_PAUSE);
});

Then(/^User select "([^"]*)" button$/, async (Button) => {
  await isElementDisplayed(Selectors.MCP.btnClick(Button), SHORT_PAUSE);
  await clickToElement(Selectors.MCP.btnClick(Button));
});

Then(/^User connect to the WordPress MCP server$/, async () => {
  await slowInputFilling(Selectors.MCP.wpSiteURL, process.env.WP_URL);
  await slowInputFilling(Selectors.MCP.wpUsername, process.env.WP_USERNAME);
  await slowInputFilling(Selectors.MCP.wpPassword, process.env.WP_PASSWORD);
  await clickToElement(Selectors.MCP.btnClick("Launch"));
  await browser.pause(LONG_PAUSE * 2);
});

Then(/^User asks obot "([^"]*)"$/, async (prompt) => {
  await slowInputFilling(Selectors.MCP.obotInput, prompt);
  await clickToElement(Selectors.MCP.submitPrompt);
  await browser.pause(LONG_PAUSE);
});

Then(/^User connect to the GitLab MCP server$/, async () => {
  await slowInputFilling(Selectors.MCP.gitlabToken, process.env.GITLAB_TOKEN);
  await clickToElement(Selectors.MCP.btnClick("Launch"));
  await browser.pause(LONG_PAUSE);
});

When(
  /^User sends prompts to Obot AI chat for "([^"]*)" MCP server$/,
  { timeout: 15 * 60 * 1000 },
  async function (serverName: string) {
    const jsonPath = path.resolve(
      process.cwd(),
      "src",
      "data",
      `${serverName.toLowerCase()}.MCP.json`,
    );
    const data = await fs.readFile(jsonPath, "utf-8");
    const { prompts, tools } = JSON.parse(data);

    this.promptResults = [];
    const toolList = tools;

    for (let i = 0; i < prompts.length; i++) {
      try {
        const result = await sendPromptValidateAndCollect(
          prompts[i],
          toolList,
          i,
        );
        this.promptResults.push(result);
      } catch (err: any) {
        console.error(`Error in prompt #${i + 1}: ${err.message}`);
        this.promptResults.push({ prompt: prompts[i], error: err.message });
      }
    }
  },
);

Then(
  /^All prompts results should be validated and report generated for selected "([^"]*)" MCP Server$/,
  async function (serverName: string) {
    const report = aggregateToolResponses(this.promptResults);
    saveMCPReport(serverName, report);

    const errors = this.promptResults.filter((r) => r.error);
    if (errors.length > 0) {
      console.warn(`${errors.length} prompts had issues.`);
    }
  },
);
