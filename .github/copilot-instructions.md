# Edge Flow Development Instructions

This document provides guidance to AI coding agents working on the edge-flow Docker Compose deployment.

## Quick Start

```bash
cd edge-flow/

# Start all services
docker compose up -d redis flow frontend mcp-server

# View logs
docker compose logs -f flow

# Stop all services
docker compose down
```

## Service Details

### Flow Backend (port 8000)
- Image: `registry.fls-engineering.de/flow_engine_wo_ai:0.7.0`
- Command: Uses `watchfiles` for hot-reload on code changes
- Volumes: Mounts `../` (project root) to `/app`
- Auto-reloads on changes to:
  - `/app/engine`
  - `/app/flowruntime`
  - `/app/packages`

### Frontend (port 4200)
- Image: `node:24-alpine`
- Command: `npx ng serve --host 0.0.0.0 --port 4200 --poll 1000`
- Volumes: Mounts `../flow-frontend` to `/app`

### Redis (ports 6379, 8004)
- Image: `redis/redis-stack:latest`
- Purpose: Message broker and caching
- IPC: Shared with other services

### MCP Server (port 8002)
- Image: `registry.fls-engineering.de/flow_engine_wo_ai:0.7.0`
- Command: MCP server via SSE transport on port 8002
- Purpose: External tool integration

## Development Workflow

### Testing Code Changes

1. Modify code in the project root (mounted to `/app` in flow container)
2. Watchfiles automatically reloads the service
3. Test via API or frontend

### Accessing Services

```bash
# Test backend API
curl http://localhost:8000/api/flow/status/flow/available-nodes

# Check health
curl http://localhost:8000/health

# View logs
docker compose logs -f flow
```

### Debugging

1. Enable debug mode in environment:
   ```yaml
   environment:
     - FLOW_DUMP_PROCESS_ERROR_MSG=true
     - FLOW_LOG_LEVEL=DEBUG
   ```

2. Check Redis connectivity:
   ```bash
   docker exec -it edge-flow-redis-1 redis-cli ping
   ```

3. View MCP server logs:
   ```bash
   docker compose logs -f mcp-server
   ```

## Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Main service definitions |
| `nodes.json` | OPC-UA server configuration |
| `settings.json` | Camera settings (shared across cameras) |

## Network Configuration

All services share the same Docker network with aliases:
- `flow` → FastAPI backend
- `redis` → Redis server
- `opcua` → OPC-UA server

## GPU Support

The flow service has GPU access configured:

```yaml
devices:
  - /dev/dri:/dev/dri   # Intel GPU (OpenCL via DRI render node)
group_add:
  - "993"               # render group GID
```

## Common Tasks

### Restart Services After Code Changes
```bash
docker compose up -d --force-recreate flow
```

### View Real-time Logs
```bash
docker compose logs -f flow frontend
```

### Access Container Shell
```bash
docker exec -it edge-flow-flow-1 bash
```

## Related Documentation

- [Main AGENTS.md](../AGENTS.md) - General project instructions
- [Docker Guide](../DOCKER.md) - Docker basics
- [Installation Guide](../INSTALL.md) - Setup requirements
