# Ghost on Render

This repository contains configurations to deploy a Ghost blog on Render.

## Local Development

To run the Ghost blog locally using Docker Compose:

```bash
docker-compose up
```

Your local Ghost instance will be available at http://localhost:2368. The Ghost admin interface will be at http://localhost:2368/ghost.

## Deployment on Render

1. Fork this repository to your GitHub account.

2. Create a new Render account if you don't have one at https://render.com

3. In the Render dashboard, click on "New" and select "Blueprint".

4. Connect your GitHub account and select the forked repository.

5. Render will automatically detect the `render.yaml` configuration file and create the required services.

6. Update the following environment variables:
   - `url`: Your Render app URL (e.g., https://your-ghost-blog.onrender.com)
   - `MAIL_USER`: Your mail service username (e.g., from Mailgun)
   - `MAIL_PASSWORD`: Your mail service password

7. Click "Apply" and wait for the deployment to finish.

## Important Notes

- The deployment includes a MySQL database for persistent storage.
- The Ghost content is stored in a volume that persists across deployments.
- The `config.production.json` file needs to be updated with your actual Render URL before deployment.

## Customization

You can customize the Ghost installation by modifying the following files:

- `Dockerfile`: Change the Ghost version or add custom packages
- `config.production.json`: Adjust Ghost configuration
- `render.yaml`: Modify the deployment configuration

## Maintenance

To update Ghost to a newer version, update the version in the Dockerfile and redeploy.
