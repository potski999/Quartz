<!-- BEGIN:agent-rules -->


## RESPONSES

- Keep responses concise and to the point - unless the user asks otherwise

# Agent Rules & Safety Protocols

## PLANNING & EXECUTION
- **No Assumptions:** Always ask clarifying questions regarding tech stack or design.
- **Coordinator Role:** Use sub-agents for research and implementation; act as the coordinator to manage the workflow.
- **Verification:** After any code change, run relevant linting, type checks, or build commands to ensure quality.

## CHANGE / EDIT MODE
- **Delegate Complexity:** Use sub-agents for implementing features; act as the coordinator to maintain the high-level architectural integrity.
- **Parallel Execution:** Break down the plan into independent modules that can be implemented in parallel by sub-agents.
- **Strategic Model Selection:** Assign tasks based on complexity: Use premium models for core logic/coding and mid-tier models for documentation or boilerplate.
- **Quality Control:** Do not blindly trust sub-agent output. After a feature is completed, you must run the project's verification suite (e.g., lint, type check, and build commands) to ensure no regressions were introduced.
- **Efficiency Rule:** For trivial changes (1-3 lines of code), implement directly rather than spawning a sub-agent to save time/tokens.

## DEPLOYMENT — STRICT RULE
- **Local Only:** All changes must be made and tested locally first.
- **No Auto-Push:** NEVER commit, push, or deploy changes to a live environment without explicit user authorization.
- **Explicit Triggers:** Do NOT use `git commit`, `git push`, or cloud deployment commands unless the user specifically says "deploy" or "push".
- **Execution Path:** Deployment must only be handled via the `Github_Push.ps1` script, initiated by the user.

## DATABASE SCHEMA CHANGES — STRICT RULE
- **Local Source Only**: Always make schema changes in the local configuration files first; never suggest manual edits in the Firebase Console.
- **Permission Boundary**: Assume you do NOT have authorization to modify the live production database directly. 
- **No Deployment Commands**: NEVER attempt to run `firebase dataconnect:sql:push` or any command that modifies the live schema.
- **User Handover**: Provide the user with the exact CLI command required to apply the changes locally and instruct the user to run it.
- **Verification**: After the user confirms the update, verify the local code reflects the new state before proceeding with feature development.

## PROJECT ORGANIZATION — STRICT RULE
- **Hosting Files**: All files intended for live web hosting must reside in the `/public` directory.
- **Database Assets**: Future SQL schemas must be placed in the `/dataconnect` directory.
- **Data Imports**: Store raw CSV files in `/data` and processing scripts in `/scripts`.
- **Admin Isolation**: NEVER include service account keys or raw data files in the `/public` directory to prevent accidental deployment to the live site.
- **Project Root**: `AGENTS.md`, `README.md`, `DESIGN.md`, `firebase.json`, `.firebaserc`, `.gitignore`, `.github/`, `skills-lock.json`, `TODO.md` stay at root.

## TESTING

- Use any testing tools, libraries available to the project for testing your changes
- Never assume your changes simply work, always test!
- If the project does not have any testing tools, scripts, MCP tools, skills, etc. available for testing, ask the user to carry out the tests.

## UI DESIGN

- Always follow the UI design system when creating or reviewing components or pages.
- Design System: @DESIGN.md
