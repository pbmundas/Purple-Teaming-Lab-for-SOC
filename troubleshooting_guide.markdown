# Troubleshooting Guide

## Common Issues and Solutions

1. **Docker Containers Not Starting**
   - **Symptom**: `docker ps` shows no containers.
   - **Solution**:
     - Verify Docker Desktop is running.
     - Check port conflicts: `netstat -aon | findstr :5678`.
     - View logs: `docker-compose logs`.
     - Reset: `bash scripts/reset.sh`.

2. **n8n Not Accessible**
   - **Symptom**: http://localhost:5678 fails.
   - **Solution**:
     - Check container: `docker ps`.
     - View logs: `docker logs n8n`.
     - Verify `N8N_ENCRYPTION_KEY` matches.

3. **ELK Stack Issues**
   - **Symptom**: Kibana shows no data.
   - **Solution**:
     - Check Elasticsearch: `docker logs elasticsearch`.
     - Verify Logstash config: `docker logs logstash`.
     - Rebuild: `docker-compose down -v && bash scripts/init.sh`.

4. **Workflows Not Executing**
   - **Symptom**: No logs in Kibana.
   - **Solution**:
     - Activate workflows in n8n.
     - Check workflow logs in n8n.
     - Verify commands in `*.json`.

## Advanced Debugging
- View logs: `docker-compose logs`.
- Access container: `docker exec -it <container_name> bash`.
- Check Docker resources in Docker Desktop.

## Getting Help
- n8n: https://docs.n8n.io
- Docker: https://docs.docker.com
- ELK: https://www.elastic.co/guide/index.html
- Community: https://community.n8n.io