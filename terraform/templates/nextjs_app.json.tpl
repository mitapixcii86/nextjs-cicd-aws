[
  {
    "name": "nextjs-app",
    "image": "${docker_image_url_nextjs}",
    "essential": true,
    "cpu": 10,
    "memory": 512,
    "links": [],
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "command": ["gunicorn", "-w", "3", "-b", ":8000", "hello_nextjs.wsgi:application"],
    "environment": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/nextjs-app",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "nextjs-app-log-stream"
      }
    }
  }
]