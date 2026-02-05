---
name: jira
description: |
  Jira API integration with managed OAuth. Search issues with JQL, create and update issues, manage projects and transitions. Use this skill when users want to interact with Jira issues, projects, or workflows.
compatibility: Requires network access and valid Maton API key
metadata:
  author: maton
  version: "1.0"
---

# Jira

Access the Jira Cloud API with managed OAuth authentication. Search issues with JQL, create and manage issues, and automate workflows.

## Quick Start

```bash
# First, get your cloud ID
curl -s -X GET 'https://gateway.maton.ai/jira/oauth/token/accessible-resources' \
  -H 'Authorization: Bearer YOUR_API_KEY'

# Then search issues
curl -s -X GET 'https://gateway.maton.ai/jira/ex/jira/{cloudId}/rest/api/3/search/jql?jql=project%3DKEY&maxResults=10' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

## Base URL

```
https://gateway.maton.ai/jira/{native-api-path}
```

Replace `{native-api-path}` with the actual Jira API endpoint path. The gateway proxies requests to `api.atlassian.com` and automatically injects your OAuth token.

## Getting Cloud ID

Jira Cloud requires a cloud ID. Get it first:

```bash
GET /jira/oauth/token/accessible-resources
```

Response:

```json
[{
  "id": "62909843-b784-4c35-b770-e4e2a26f024b",
  "url": "https://yoursite.atlassian.net",
  "name": "yoursite"
}]
```

## Authentication

All requests require the Maton API key in the Authorization header:

```
Authorization: Bearer YOUR_API_KEY
```

**Environment Variable:** Set your API key as `MATON_API_KEY`:

```bash
export MATON_API_KEY="YOUR_API_KEY"
```

### Getting Your API Key

1. Sign in or create an account at [maton.ai](https://maton.ai)
2. Go to [maton.ai/settings](https://maton.ai/settings)
3. Copy your API key

## Connection Management

Manage your Jira OAuth connections at `https://ctrl.maton.ai`.

### List Connections

```bash
curl -s -X GET 'https://ctrl.maton.ai/connections?app=jira&status=ACTIVE' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

### Create Connection

```bash
curl -s -X POST 'https://ctrl.maton.ai/connections' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -d '{"app": "jira"}'
```

### Get Connection

```bash
curl -s -X GET 'https://ctrl.maton.ai/connections/{connection_id}' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

**Response:**
```json
{
  "connection": {
    "connection_id": "21fd90f9-5935-43cd-b6c8-bde9d915ca80",
    "status": "ACTIVE",
    "creation_time": "2025-12-08T07:20:53.488460Z",
    "last_updated_time": "2026-01-31T20:03:32.593153Z",
    "url": "https://connect.maton.ai/?session_token=...",
    "app": "jira",
    "metadata": {}
  }
}
```

Open the returned `url` in a browser to complete OAuth authorization.

### Delete Connection

```bash
curl -s -X DELETE 'https://ctrl.maton.ai/connections/{connection_id}' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

### Specifying Connection

If you have multiple Jira connections, specify which one to use with the `Maton-Connection` header:

```bash
curl -s -X GET 'https://gateway.maton.ai/jira/ex/jira/{cloudId}/rest/api/3/project' \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Maton-Connection: 21fd90f9-5935-43cd-b6c8-bde9d915ca80'
```

If omitted, the gateway uses the default (oldest) active connection.

## API Reference

### Projects

#### List Projects

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/project
```

#### Get Project

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/project/{projectKeyOrId}
```

### Issues

#### Search Issues (JQL)

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/search/jql?jql=project%3DKEY%20order%20by%20created%20DESC&maxResults=20&fields=summary,status,assignee
```

#### Get Issue

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/issue/{issueIdOrKey}
```

#### Create Issue

```bash
POST /jira/ex/jira/{cloudId}/rest/api/3/issue
Content-Type: application/json

{
  "fields": {
    "project": {"key": "PROJ"},
    "summary": "Issue summary",
    "issuetype": {"name": "Task"}
  }
}
```

#### Update Issue

```bash
PUT /jira/ex/jira/{cloudId}/rest/api/3/issue/{issueIdOrKey}
Content-Type: application/json

{
  "fields": {
    "summary": "Updated summary"
  }
}
```

#### Delete Issue

```bash
DELETE /jira/ex/jira/{cloudId}/rest/api/3/issue/{issueIdOrKey}
```

#### Assign Issue

```bash
PUT /jira/ex/jira/{cloudId}/rest/api/3/issue/{issueIdOrKey}/assignee
Content-Type: application/json

{
  "accountId": "712020:5aff718e-6fe0-4548-82f4-f44ec481e5e7"
}
```

### Transitions

#### Get Transitions

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/issue/{issueIdOrKey}/transitions
```

#### Transition Issue (change status)

```bash
POST /jira/ex/jira/{cloudId}/rest/api/3/issue/{issueIdOrKey}/transitions
Content-Type: application/json

{
  "transition": {"id": "31"}
}
```

### Comments

#### Get Comments

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/issue/{issueIdOrKey}/comment
```

#### Add Comment

```bash
POST /jira/ex/jira/{cloudId}/rest/api/3/issue/{issueIdOrKey}/comment
Content-Type: application/json

{
  "body": {
    "type": "doc",
    "version": 1,
    "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Comment text"}]}]
  }
}
```

### Users

#### Get Current User

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/myself
```

#### Search Users

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/user/search?query=john
```

### Metadata

#### List Issue Types

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/issuetype
```

#### List Priorities

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/priority
```

#### List Statuses

```bash
GET /jira/ex/jira/{cloudId}/rest/api/3/status
```

## Code Examples

### JavaScript

```javascript
// Get cloud ID first
const resources = await fetch(
  'https://gateway.maton.ai/jira/oauth/token/accessible-resources',
  { headers: { 'Authorization': `Bearer ${process.env.MATON_API_KEY}` } }
).then(r => r.json());

const cloudId = resources[0].id;

// Search issues
const issues = await fetch(
  `https://gateway.maton.ai/jira/ex/jira/${cloudId}/rest/api/3/search/jql?jql=project=KEY`,
  { headers: { 'Authorization': `Bearer ${process.env.MATON_API_KEY}` } }
).then(r => r.json());
```

### Python

```python
import os
import requests

headers = {'Authorization': f'Bearer {os.environ["MATON_API_KEY"]}'}

# Get cloud ID
resources = requests.get(
    'https://gateway.maton.ai/jira/oauth/token/accessible-resources',
    headers=headers
).json()

cloud_id = resources[0]['id']

# Search issues
issues = requests.get(
    f'https://gateway.maton.ai/jira/ex/jira/{cloud_id}/rest/api/3/search/jql',
    headers=headers,
    params={'jql': 'project=KEY', 'maxResults': 10}
).json()
```

## Notes

- Always fetch cloud ID first using `/oauth/token/accessible-resources`
- JQL queries must be bounded (e.g., `project=KEY`)
- Use URL encoding for JQL query parameters
- Update, Delete, Transition return HTTP 204 on success
- Agile API requires additional OAuth scopes

## Error Handling

| Status | Meaning |
|--------|---------|
| 400 | Missing Jira connection or invalid JQL |
| 401 | Invalid or missing Maton API key |
| 429 | Rate limited (10 req/sec per account) |
| 4xx/5xx | Passthrough error from Jira API |

## Resources

- [Jira API Introduction](https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/)
- [Search Issues (JQL)](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-search-jql-get)
- [Get Issue](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-get)
- [Create Issue](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-post)
- [Transition Issue](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-issueidorkey-transitions-post)
- [JQL Reference](https://support.atlassian.com/jira-service-management-cloud/docs/use-advanced-search-with-jira-query-language-jql/)
