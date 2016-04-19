var TestResponses = {
    tasks: {
        paginate: {
            success: {
                status: 200,
                contentType: 'text/html',
                responseText: 'Freshly baked tasks'
            }
        },
        wip: {
            success: {
                status: 200,
                responseText: '{"message": "Task work in progress"}'
            },
            task_not_found: {
                status: 403,
                responseText: '{"message": "Cannot find the task!"}'
            },
            error_assigning: {
                status: 500,
                responseText: '{"message": "Error message"}'
            }
        },
        done: {
            success: {
                status: 200,
                responseText: '{"message": "Task work in progress"}'
            },
            task_not_found: {
                status: 403,
                responseText: '{"message": "Cannot find the task!"}'
            },
            error_assigning: {
                status: 500,
                responseText: '{"message": "Error message"}'
            }
        }
    },
    jobs: {
        paginate: {
            success: {
                status: 200,
                contentType: 'text/html',
                responseText: 'Freshly baked jobs'
            }
        }
    }
};
