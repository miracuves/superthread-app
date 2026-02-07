# GitHub Issues to Create

This document contains all GitHub issues ready to be created for the Superthread Flutter App project.

## How to Create These Issues

### Option 1: Manual Creation via GitHub Web UI
1. Go to: https://github.com/miracuves/superthread-app/issues/new
2. Copy each issue's title and description below
3. Create the issue with appropriate labels

### Option 2: Using GitHub API (requires Personal Access Token)
See GitHub documentation for API usage.

---

## Issues to Create

### Issue #1: Implement External Links UI Component

**Title:** Implement External Links UI for GitHub/GitLab Integration

**Labels:** enhancement, feature, ui, good first issue

**Priority:** High

**Description:**
Implement UI components to display external links (GitHub PRs, GitLab MRs, generic links) on cards.

**Requirements:**
- Create ExternalLinkWidget with GitHub/GitLab PR display
- Show status badges (open, merged, closed)
- Integrate with CardDetailScreen
- Handle tap to open in browser
- Widget tests with >80% coverage

**Acceptance Criteria:**
- [ ] ExternalLinkWidget created and tested
- [ ] GitHub PRs display with correct status
- [ ] Generic links display with favicon
- [ ] All links open in external browser
- [ ] Empty state handled gracefully

---

### Issue #2: Implement Card Hints UI Component

**Title:** Implement AI-Powered Card Hints UI

**Labels:** enhancement, feature, ui, ai

**Priority:** Medium

**Description:**
Implement UI components to display AI-powered hints on cards (tag suggestions and related cards).

**Acceptance Criteria:**
- [ ] CardHintWidget created and tested
- [ ] Tag hints display correctly
- [ ] Relation hints show similarity scores
- [ ] Dismiss functionality works
- [ ] Navigation to related cards works

---

### Issue #3: Implement Cover Image UI Component

**Title:** Implement Advanced Cover Image Display

**Labels:** enhancement, feature, ui

**Priority:** Medium

**Description:**
Implement enhanced cover image display with support for images, gradients, colors, and emojis.

**Acceptance Criteria:**
- [ ] CoverImageWidget supports all types
- [ ] Blurhash loading works smoothly
- [ ] Emoji scaling is responsive
- [ ] PositionY offset works correctly
- [ ] Performance tested with large images

---

### Issue #4: Add Estimate Field UI

**Title:** Implement Story Point Estimate Field

**Labels:** enhancement, feature, ui

**Priority:** Low

**Description:**
Add UI for displaying and editing story point estimates on cards.

**Acceptance Criteria:**
- [ ] Estimate displays on card
- [ ] Edit functionality works
- [ ] API integration complete
- [ ] Validation (1-21 range)

---

### Issue #5: Complete Comment Threading Feature

**Title:** Implement Nested Comment Threading UI

**Labels:** enhancement, feature, ui, complex

**Priority:** High

**Description:**
Implement full comment threading support with nested replies, indentation, and collapse/expand functionality.

**Requirements:**
- Create ThreadedCommentWidget with recursive rendering
- Support 5 levels of nesting with indentation
- Collapse/expand toggle
- Reply to specific comments
- Thread line connectors

**Acceptance Criteria:**
- [ ] ThreadedCommentWidget handles 5+ levels of nesting
- [ ] Collapse/expand works smoothly
- [ ] Reply to specific comment works
- [ ] Thread lines render correctly
- [ ] Performance tested with 100+ comments
- [ ] Accessibility verified

---

### Issue #6: Update Board Model with Missing Fields

**Title:** Add Missing API Fields to Board Model

**Labels:** enhancement, data-model, good first issue

**Priority:** Medium

**Description:**
Update the Board model to include missing fields: is_public, public_settings, webhook_notifications, forms, vcs_mapping.

**Acceptance Criteria:**
- [ ] All 5 fields added to Board model
- [ ] Supporting models created
- [ ] JSON serialization works
- [ ] Widget tests for models

---

### Issue #7: Update User Model with Missing Fields

**Title:** Add Missing API Fields to User Model

**Labels:** enhancement, data-model, good first issue

**Priority:** Low

**Description:**
Update the User model to include missing fields: timezone_id, locale, job_description.

**Acceptance Criteria:**
- [ ] Fields added to User model
- [ ] JSON serialization works
- [ ] Profile update UI implemented
- [ ] Timezone/locale used in app

---

## Summary

| Issue | Title | Priority | Complexity |
|-------|-------|----------|------------|
| #1 | External Links UI | High | Low |
| #2 | Card Hints UI | Medium | Medium |
| #3 | Cover Image UI | Medium | Medium |
| #4 | Estimate Field UI | Low | Low |
| #5 | Comment Threading | High | High |
| #6 | Board Model Update | Medium | Low |
| #7 | User Model Update | Low | Low |

## Recommended Implementation Order

1. **#5 Comment Threading** - Highest value feature
2. **#1 External Links UI** - High demand integration
3. **#6 Board Model** - Foundation for other features
4. **#2 Card Hints UI** - AI enhancement
5. **#3 Cover Image UI** - Visual improvement
6. **#4 Estimate Field** - Agile feature
7. **#7 User Model** - Profile enhancement
