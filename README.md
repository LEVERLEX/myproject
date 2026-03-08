instructions.md
LEVERLEX Automation Framework – Structured Response
Objective ✅
Establish a production-grade, automation-safe development environment for the LEVERLEX GitHub Pages dashboard.
Integrate AI-assisted coding tools for active workflow automation:
Tabnine – AI code completion across IDEs; trained on public/open-source code.
Codeium – Free multi-language coding assistant.
Amazon CodeWhisperer – Cloud-integrated coding and deployment hints.
Replit Ghostwriter – Direct AI-assisted coding within the LEVERLEX GitHub Pages environment.
Strength: Ideal for generating boilerplate, integration scripts, and consistent coding patterns while maintaining automation alignment.
Scope
This configuration will ensure:
[x] Full workflow automation with:
GitHub Actions Bots (PRs, merges, automated testing, releases)
GitLab Auto DevOps pipelines (testing, building, deployment)
Jenkins AI plugins (error detection, monitoring, automated suggestions)
n8n / Zapier Bots (cross-platform triggered automation)
[x] Standardized dashboard.html structure
[x] Mobile-first responsive layouts
[x] Markdown integrity
[x] Automation modules conform to repository conventions
[x] Workflow files protected from unsafe edits
Required Actions ✅
1️⃣ GitHub Actions / Workflow Bots
Create .github/copilot-instructions.md for automation-aware coding instructions.
Maintain multi-platform automation triggers for PRs, commits, testing, and releases.
2️⃣ Repository Rules
[x] Enforce semantic HTML structure (H1–H10 hierarchy)
[x] Mobile-first responsive layout
[x] No inline CSS; use structured stylesheets
[x] Safe JS fetch patterns with graceful fallbacks
[x] Preserve automation workflow logic
[ ] Restrict edits to workflow YAML unless explicitly referenced
3️⃣ Automation Awareness
Respect workflow triggers (GitHub Actions, Jenkins, n8n/Zapier)
Maintain dynamic badge integrity
Preserve fallback values for API failures
Retain embedded external resources (Docs, Slides, Maps, Videos)
Acceptance Criteria ✅
[x] Multi-agent workflow automation configured and verified
[x] Repository-specific coding standards documented
[x] Automation safeguards in place
[x] Dashboard layout and formatting rules enforced
[x] All changes reviewed and merged
Outcome
The system provides:
[x] Context-aware AI coding suggestions
[x] Automation-safe updates for workflows and files
[x] Consistent, fully responsive dashboard structure
[x] Reduced manual corrections and maintenance cycles
✅ Implementation ensures reliability, maintainability, and full automation safety for the LEVERLEX GitHub Pages dashboard.