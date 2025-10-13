# Ghost on Render with PostgreSQL

This repository contains everything you need to deploy [Ghost](https://ghost.org) on Render with PostgreSQL as the database backend.

## Features

* Uses the official [Ghost Docker image](https://hub.docker.com/_/ghost) (v5.14.1)
* Uses PostgreSQL instead of MySQL for the database
* Uses [Render Disks](https://render.com/docs/disks) for permanent SSD storage for uploaded files and content
* Automatic environment configuration

## Deployment Instructions

1. Fork or push this repository to your GitHub account
2. Log in to your Render account at https://render.com
3. Click on the "New" button and select "Blueprint"
4. Connect your GitHub account and select this repository
5. Render will detect the `render.yaml` file and create the required services:
   - A web service running Ghost
   - A PostgreSQL database
   - Persistent disk storage for content
6. Click "Apply" to start the deployment

## Configuration

The configuration is automatically managed using environment variables:
- Ghost is configured to use PostgreSQL
- Database connection details are automatically passed from the PostgreSQL service to Ghost
- The site URL is automatically updated based on your Render URL

## Customization

After deployment, access the Ghost admin panel at `https://your-ghost-app-name.onrender.com/ghost` to:
1. Set up your admin account
2. Customize your site theme
3. Start creating content

**Note**: Both the Ghost web service and PostgreSQL database use persistent storage, so your data will be preserved between deployments.
