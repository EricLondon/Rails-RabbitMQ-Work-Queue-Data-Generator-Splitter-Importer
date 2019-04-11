### Rails RabbitMQ Work Queue Data Generator Splitter Importer

```
# initial setup
git clone
rake db:create db:migrate
brew services start rabbitm

# start some workers
rake data:start_worker &
rake data:start_worker &
rake data:start_worker &
rake data:start_worker &

# generate model CSV data
rake "data:generate[person, 1000000]"

# split CSV data
rake data:split_input_files

# import CSV files
rake data:import_files

# monitor
http://localhost:15672/#/queues/%2F/task_queue
```