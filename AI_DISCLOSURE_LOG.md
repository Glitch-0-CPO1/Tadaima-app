# AI Disclosure & Prompt Audit Log

**Course:** ITMSD1 - Introduction to Mobile Design and Tools (1st Sem 2026-2027)
**Event:** ITMSD1 Inter-Class Mobile Hackathon (Section C & Section F)

| | |
|---|---|
| **Team ID** | F-7 |
| **Team Name** | Tadaima |
| **Project Title** | Tadaima: A Commute Safety Companion for Students |
| **UN SDG Track** | SDG 5: Gender Equality (supporting: SDG 11, SDG 16) |

| Member | Role |
|---|---|
| Krizter Tayag | Lead UI/UX (Team Leader) |
| Aira S. Esarza | Lead Mobile Developer |
| Miques Vajay Malintad | Product & AI Specialist |

> This log is maintained continuously throughout the 4-week hackathon. Every non-trivial use of generative AI is recorded with the tool, the prompt, a summary of the output, what the team changed, and what we learned.

---

## Summary of AI Tools Used

| Tool | Purpose | Weeks |
|---|---|---|
| Claude (Anthropic, Claude Sonnet 5.5, via claude.ai) | Planning, ideation, feasibility advice, naming and documentation drafts | Week 1 |
| Figma and other design tools | Creating the prototype design | Week 1 |
| OpenCode (in VS Code) | Code generation and debugging | Starts Week 3 (entries to be added) |

---

## Team AI Audit Log

### Entry 1: Understanding the hackathon requirements
- **Date & Milestone:** 2026-10-15 | Week 1 (Orientation)
- **Tool & Model:** Claude (Claude Sonnet 5.5), claude.ai
- **Member Responsible:** Krizter Tayag (Lead UI/UX / Team Leader)
- **Prompt:** Uploaded the five official hackathon documents (Deliverables Guide, Judging Scorecard, Pitch Deck Guide, Weekly Progress Report Template, AI Disclosure Log Template) with the instruction: "scan all this file and tell me what should we do to accomplish this task."
- **AI Output Summary:** A summary of the rules (team size, 5 final deliverables, 4-week roadmap, 100-point rubric) and a day-0 and weekly action plan. It also flagged unclear points to confirm with the instructor (pivot window, deadlines, pitch timing).
- **Human Edits & Learnings:**
  - Edits: We checked the summary against the original documents and the Master Tracker sheet instead of relying on it blindly.
  - Learning: Judges grade design, a stable build, and AI documentation heavily (25 + 25 + 15 of 100 points), so a small, stable app is better than an ambitious one.

### Entry 2: Brainstorming project ideas by SDG
- **Date & Milestone:** 2026-10-15 | Week 1 (Ideation)
- **Tool & Model:** Claude (Claude Sonnet 5.5), claude.ai
- **Member Responsible:** Miques Vajay Malintad (Product & AI Specialist)
- **Prompt:** "Suggest a winnable project that has solid value and is worth trying," followed by screenshots of the Master Tracker's SDG distribution, then requests for ideas under SDG 3 and SDG 9, and SDG 13.
- **AI Output Summary:** Multiple candidate ideas per SDG (for example dengue hotspot reporting, PWD accessibility ratings, heat-stress guide for outdoor workers), each with a persona, screens, and risks. It also advised checking the tracker for overlapping titles.
- **Human Edits & Learnings:**
  - Edits: We did not adopt any of these ideas directly. We used them to compare options, then developed our own concept from a community problem we know about (see Entry 3).
  - Learning: How to check topic exclusivity through the tracker and why differentiation within the same SDG matters.

### Entry 3: Enhancing and stress-testing our own concept
- **Date & Milestone:** 2026-10-15 | Week 1 (Problem Framing)
- **Tool & Model:** Claude (Claude Sonnet 5.5), claude.ai
- **Member Responsible:** Aira S. Esarza (Lead Mobile Developer)
- **Prompt:** We described our own idea (an app for parents to track their students, especially girls commuting late who get harassed by drivers, with an SOS button) and asked: "can you enhance my idea, and tell me is it possible to do it? where does it belong?" We then asked how it differs from calling or texting, whether it can work offline, and whether it is feasible for students.
- **AI Output Summary:** Reframed the idea as a trip-based safety app with driver and plate logging and SOS, and mapped it to SDG 5. It explained the differences from calling and texting, how GPS and SMS can work without mobile data, and a feasibility breakdown (core MVP versus risky features such as live multi-device tracking and background auto-SMS).
- **Human Edits & Learnings:**
  - Edits: The original problem and idea came from our community. After reviewing the feasibility analysis, the team decided to drop the live tracking version because it was too risky for the time available.
  - Learning: GPS works without internet but sending data to another phone needs a network; privacy and consent matter when tracking minors; scope control protects the demo.

### Entry 4: Simplifying the concept to a feasible MVP
- **Date & Milestone:** 2026-10-15 | Week 1 (Scope Definition)
- **Tool & Model:** Claude (Claude Sonnet 5.5), claude.ai
- **Member Responsible:** Miques Vajay Malintad (Product & AI Specialist)
- **Prompt:** "Can you elaborate the 'safe places and trusted contacts'" and "is it possible to do it along with the optional features you suggest?"
- **AI Output Summary:** An elaborated concept with a ride log, safe places list, trusted contacts, and a hold-to-confirm SOS that opens a pre-filled SMS. It also gave a feature-by-feature effort and risk table and a build order.
- **Human Edits & Learnings:**
  - Edits: [Team to record the final chosen feature list and anything cut or added]
  - Learning: Building the core first, then adding optional features only when stable, keeps the app demo-ready at all times.

### Entry 5: Project name and SDG mapping
- **Date & Milestone:** 2026-10-15 | Week 1 (Branding)
- **Tool & Model:** Claude (Claude Sonnet 5.5), claude.ai
- **Member Responsible:** Krizter Tayag (Lead UI/UX / Team Leader)
- **Prompt:** "What should we name our project? and where does it belong in the SDGs?"
- **AI Output Summary:** Suggested names (SafeBiyahe, UwiLigtas, Bantay Biyahe, SafeUwi, Kasama sa Daan) and recommended SDG 5 as the primary track.
- **Human Edits & Learnings:**
  - Edits: We did not use any suggested name. The team created the name **"Tadaima"** (Japanese for "I'm home") ourselves, and the AI only reviewed it and suggested taglines. The title was registered in the Master Tracker and approved by our instructor.
  - Learning: A good name should connect to the core feature (our "Tadaima" button) and be explained with a clear subtitle.

### Entry 6: Repository setup and README
- **Date & Milestone:** 2026-10-16 | Week 1 (Setup)
- **Tool & Model:** Claude (Claude Sonnet 5.5), claude.ai
- **Member Responsible:** Krizter Tayag (Lead UI/UX / Team Leader)
- **Prompt:** Questions about creating the GitHub repository, what to set in the repo creation form, and a README template.
- **AI Output Summary:** Step-by-step setup guidance (public repo, Dart .gitignore, README) and a README template.
- **Human Edits & Learnings:**
  - Edits: We filled in our team details (Team F-7) and adjusted the text to match our project.
  - Learning: Why a public repo, a complete README, and this log in the repo root are required by the rubric.

### Entry 7: Drafting this log
- **Date & Milestone:** 2026-10-16 | Week 1 (Documentation)
- **Tool & Model:** Claude (Claude Sonnet 5.5), claude.ai
- **Member Responsible:** Krizter Tayag (Lead UI/UX / Team Leader)
- **Prompt:** "Go write my AI_Disclosure_Log.md" (using the instructor's template), then a follow-up asking for a full version with our team details filled in.
- **AI Output Summary:** A first draft of this file summarizing the AI interactions above, then an updated version with Team F-7's names, roles, and entry owners.
- **Human Edits & Learnings:**
  - Edits: We supplied the team ID, team name, member names, roles, and which member owns each entry. [Team to add any further corrections made after review]
  - Learning: The log must be accurate and in our own words, because we defend it during the viva.

### Entries 8 onward (to be added)
Add a new entry for every non-trivial AI use in Weeks 2 to 4, especially each OpenCode prompt, in this format:

- **Date & Milestone:**
- **Tool & Model:**
- **Member Responsible:**
- **Prompt (exact):**
- **AI Output Summary:**
- **Human Edits & Learnings:**

---

## Academic Honesty & Transparency Declaration

We hereby declare that all entries recorded in this AI Disclosure Log represent a truthful, accurate, and comprehensive accounting of the artificial intelligence tools used during this hackathon. All designs, architectures, and code submitted have been verified, understood, and can be fully explained and defended individually by our team members during the Demo Day oral defense.

| Team Member Name | Signature | Date |
|---|---|---|
| Member 1: Krizter Tayag | ________________ | YYYY-MM-DD |
| Member 2: Aira S. Esarza | ________________ | YYYY-MM-DD |
| Member 3: Miques Vajay Malintad | ________________ | YYYY-MM-DD |
