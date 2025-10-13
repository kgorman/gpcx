# Ghost on Render

A simple and clean Ghost deployment on Render with PostgreSQL database.

## Deployment Instructions

1. Fork this repository to your GitHub account.
2. Log in to your Render account at https://render.com.
3. Click on the "New" button and select "Blueprint".
4. Connect your GitHub account and select this repository.
5. Render will detect the `render.yaml` file and create the required services.
6. Update the `url` environment variable with your actual Render URL.
7. Click "Apply" to start the deployment.

## What's Included

- Ghost CMS latest version
- PostgreSQL database (free tier)
- Persistent disk storage for content

## Configuration

The setup is configured to use PostgreSQL as the database. The database connection details are automatically passed to Ghost using environment variables.

## Customization

To customize your Ghost blog, access the admin panel at `https://your-blog-url.onrender.com/ghost` after deployment.
