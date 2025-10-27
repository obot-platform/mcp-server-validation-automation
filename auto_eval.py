import os
import json
import glob
from openai import OpenAI

EVAL_CONFIG = {
    "grading_model": "gpt-4o-mini",
    "prompt": """
You are an expert evaluator for AI chat systems.
Given the user's prompt and the assistant's response,
evaluate whether the response correctly, clearly, and completely addresses the user's prompt.

- If the assistant's response fulfills the user request or explains failure clearly, respond with a JSON object:
  {
    "result": "SUCCESS",
    "task_done": true
  }

- If the assistant's response indicates the task was NOT done, but explains why, respond with:
  {
    "result": "Response given, but Task Failed",
    "task_done": false,
    "reason": "explanation why task was not done"
  }

- If the response is incorrect, incomplete, irrelevant, or contradictory, respond with:
  {
    "result": "FAILURE"
  }

Output strictly a single JSON object as shown.
""",
    "input_key": "prompt",
    "output_key": "response"
}

def create_grading_prompt(template, user_prompt, assistant_response):
    return template.replace("the user's prompt", f'"{user_prompt}"').replace(
        "the assistant's response", f'"{assistant_response}"'
    )

def grade_response(client, model, prompt):
    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "system", "content": prompt}]
    )
    content = response.choices[0].message.content.strip()
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        return {"result": "FAILURE", "reason": "Invalid JSON response: " + content}

def enhance_report_with_eval(original_data, client, model, prompt_template, input_key, output_key):
    # For each prompt and tool in the original JSON, add grading details
    for prompt_id, prompt_data in original_data.items():
        prompt_text = prompt_data['promptText']
        for tool_name, tool_data in prompt_data['tools'].items():
            assistant_response = " ".join(tool_data.get("responses", []))
            grading_prompt = create_grading_prompt(prompt_template, prompt_text, assistant_response)
            grade_info = grade_response(client, model, grading_prompt)
            # Insert grading into the tool
            tool_data["task_done"] = grade_info.get("task_done", None)
            # Merge both 'reason' field from grade_info and 'errors' from original data into 'failure_reason'
            reasons = []
            if "reason" in grade_info:
                reasons.append(grade_info["reason"])
            errors = tool_data.get("errors", [])
            if errors:
                reasons.extend(errors)
            # Only add failure_reason if there's something to include
            tool_data["failure_reason"] = reasons if reasons else []
            # Optionally, update status based on grade
            if grade_info.get("result") == "FAILURE":
                tool_data["status"] = "Failure"
            elif grade_info.get("task_done") is True:
                tool_data["status"] = "Success"
            elif grade_info.get("task_done") is False:
                tool_data["status"] = "Failure"
            # else leave status as is
            # Remove original "errors" field to avoid duplication
            if "errors" in tool_data:
                del tool_data["errors"]
    return original_data

def main():
    reports_folder = os.path.join(os.path.dirname(os.path.abspath(__file__)), "MCP Server Reports")
    json_files = glob.glob(os.path.join(reports_folder, "*.json"))

    print(f"Found {len(json_files)} report files to process...")

    # Initialize OpenAI client
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise EnvironmentError("OPENAI_API_KEY is not set.")
    client = OpenAI()

    model = EVAL_CONFIG["grading_model"]
    prompt_template = EVAL_CONFIG["prompt"]
    input_key = EVAL_CONFIG["input_key"]
    output_key = EVAL_CONFIG["output_key"]

    for json_path in json_files:
        print(f"\nEnhancing {os.path.basename(json_path)} ...")
        with open(json_path, "r", encoding="utf-8") as f:
            original_data = json.load(f)

        enhanced_report = enhance_report_with_eval(original_data, client, model, prompt_template, input_key, output_key)

        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(enhanced_report, f, indent=2)
        print(f"Overwritten original report file with enhanced data: {os.path.basename(json_path)}")
    print("\nAll reports processed and enhanced successfully.")

if __name__ == "__main__":
    main()
