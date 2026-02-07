# GitHub Issues Template and Guide

This document describes how to create and manage GitHub Issues for the Superthread Flutter App.

## 📋 Issue Types

### 1. Bug Reports
For reporting problems with the app.

### 2. Feature Requests
For suggesting new features or enhancements.

### 3. Documentation
For improvements to documentation.

### 4. Performance
For reporting performance issues.

---

## 🐛 Bug Report Template

```markdown
### 🐛 Bug Description
A clear and concise description of what the bug is.

### 🔢 Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

### 📱 Expected Behavior
A clear and concise description of what you expected to happen.

### 📸 Screenshots
If applicable, add screenshots to help explain your problem.

### 📋 Environment
- OS: [e.g. iOS 15.0, Android 12]
- App Version: [e.g. 1.0.0]
- Device: [e.g. iPhone 13, Samsung Galaxy S21]

### 📝 Logs
```
Paste relevant logs here
```

### 📌 Additional Context
Add any other context about the problem here.
```

---

## ✨ Feature Request Template

```markdown
### 🎯 Feature Description
A clear and concise description of the feature you'd like to see.

### 💡 Use Case
Describe the use case and why this feature would be beneficial.

### 📐 Proposed Solution
A clear description of how you want the feature to work.

### 🔄 Alternatives Considered
Describe any alternative solutions or features you've considered.

### 📸 Mockups
If applicable, add mockups or screenshots to illustrate the feature.

### 📌 Additional Context
Any other context or screenshots about the feature request.
```

---

## 🏷️ Labels

Use these labels to categorize issues:

### Priority
- `critical` - Urgent, needs immediate attention
- `high` - Important, should be addressed soon
- `medium` - Normal priority
- `low` - Nice to have, can wait

### Type
- `bug` - Bug report
- `enhancement` - Feature request
- `documentation` - Documentation issue
- `performance` - Performance issue
- `security` - Security vulnerability

### Status
- `status: needs-triage` - Not yet reviewed
- `status: ready-for-dev` - Approved for development
- `status: in-progress` - Currently being worked on
- `status: in-review` - Under review
- `status: done` - Completed

### Component
- `component: auth` - Authentication
- `component: boards` - Boards feature
- `component: cards` - Cards feature
- `component: ui` - User interface
- `component: api` - API integration
- `component: storage` - Data storage

### Platform
- `platform: ios` - iOS specific
- `platform: android` - Android specific
- `platform: web` - Web specific
- `platform: desktop` - Desktop specific

---

## 📊 Current Issues to Track

### Critical Issues

#### Issue #1: Add Missing API Fields to Data Models
**Type:** Enhancement  
**Priority:** High  
**Status:** In Progress  
**Labels:** `enhancement`, `component: api`, `status: in-progress`

**Description:**
Add missing fields from official Superthread API to data models:
- `external_links` - GitHub/GitLab PR integrations
- `estimate` - Card estimate field
- `hints` - Smart suggestions
- `cover_image` - Advanced image positioning
- User timezone/locale fields

**Tasks:**
- [x] Create ExternalLink model
- [x] Create CardHint model
- [x] Create CoverImage model
- [ ] Update Card model with new fields
- [ ] Update Board model with new fields
- [ ] Update User model with new fields
- [ ] Generate JSON serialization code
- [ ] Add unit tests for new models

**Related:** https://superthread.com/docs/api-docs

---

#### Issue #2: Implement Comment Threading
**Type:** Enhancement  
**Priority:** Medium  
**Status:** Ready for Dev  
**Labels:** `enhancement`, `component: ui`, `status: ready-for-dev`

**Description:**
Implement nested comment replies with proper threading UI.

**Tasks:**
- [ ] Update Comment model to support children
- [ ] Add parent_comment_id field
- [ ] Implement nested comment widget
- [ ] Add indentation for replies
- [ ] Add reply button to comments
- [ ] Add collapse/expand functionality
- [ ] Add unit tests
- [ ] Add widget tests

---

#### Issue #3: Add External Links UI
**Type:** Feature  
**Priority:** Medium  
**Status:** Ready for Dev  
**Labels:** `enhancement`, `component: ui`, `status: ready-for-dev`

**Description:**
Add UI to display and manage external links (GitHub PRs, etc.) on cards.

**Tasks:**
- [ ] Create ExternalLinkWidget
- [ ] Add to CardDetailScreen
- [ ] Display PR status (open/closed/merged)
- [ ] Handle link clicks
- [ ] Add PR metadata display
- [ ] Add tests

---

#### Issue #4: Verify and Fix API Base URL
**Type:** Bug Fix  
**Priority:** Critical  
**Status:** Done ✅  
**Labels:** `bug`, `component: api`, `status: done`

**Description:**
Verify that the API base URL matches the official Superthread API.

**Resolution:**
✅ API base URL is correct: `https://api.superthread.com/v1`

---

#### Issue #5: Create Development Workflow Documentation
**Type:** Documentation  
**Priority:** Medium  
**Status:** Done ✅  
**Labels:** `documentation`, `status: done`

**Description:**
Create comprehensive development workflow documentation.

**Resolution:**
✅ Created DEVELOPMENT_WORKFLOW.md with:
- Environment setup
- Branching strategy
- Commit conventions
- Code style guidelines
- Testing guidelines
- PR process
- Release process

---

## 🎯 Roadmap Issues

### Version 1.1 - API Enhancement
- [ ] Add all missing API fields
- [ ] Implement comment threading
- [ ] Add external links support
- [ ] Improve error handling
- [ ] Add comprehensive tests

**Target Release:** Q2 2026

### Version 1.2 - Performance & Offline
- [ ] Implement offline caching
- [ ] Add real-time WebSocket updates
- [ ] Improve app performance
- [ ] Optimize image loading
- [ ] Add battery optimizations

**Target Release:** Q3 2026

### Version 2.0 - Advanced Features
- [ ] Full offline support
- [ ] Advanced search filters
- [ ] Custom themes
- [ ] Biometric authentication
- [ ] AI-powered suggestions

**Target Release:** Q4 2026

---

## 📝 Creating New Issues

### Best Practices

1. **Search first** - Check if the issue already exists
2. **Use templates** - Fill out the appropriate template
3. **Be specific** - Provide clear details and examples
4. **Add labels** - Apply appropriate labels
5. **Set priority** - Mark priority level
6. **Link related issues** - Add references to related issues
7. **Assign milestones** - Add to appropriate milestone/release

### Issue Lifecycle

1. **Opened** → Issue created
2. **Needs Triage** → Awaiting review
3. **Ready for Dev** → Approved, awaiting developer
4. **In Progress** → Being worked on
5. **In Review** → Pull request submitted
6. **Done** → Completed and merged

---

## 🔗 Useful Links

- [GitHub Issues](https://github.com/miracuves/superthread-app/issues)
- [GitHub Pull Requests](https://github.com/miracuves/superthread-app/pulls)
- [Superthread API Docs](https://superthread.com/docs/api-docs)
- [Project README](./README.md)
- [Development Workflow](./DEVELOPMENT_WORKFLOW.md)

