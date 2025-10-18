# Task Tracker
This is another todo list app, but tailored for less organized person.

## Technical stack
We use flutter to develop our app.

## Pages
### Homepage
A list view showing all pending tasks, sorted by a given order like create time, deadline, or priority level.

A button to add new task.

A button to record today's work, which will navigate user to "Record progress page".

User will navigate through different pages via tab bar at the bottom, they are "Task management page" and "Gantt chart page". 

Users can switch between sorting methods (create time, deadline, priority level) via a dropdown/selector in the UI.

### Record progress page
In this page we go through user's all on going tasks. Similar to dating apps, each time display one task and give user option to choose from how many hours they spent on the task today. Options are "less than 2 hours", "2 to 4 hours", "4-8 hours", "not at all", or allow user to input an exact number of hours. These responses will be recorded (enum values stored as negative numbers, exact input stored as positive numbers). 

Each task card also includes a checkbox for "task completed today" to mark tasks as complete.

### Task management page
A list view allow user to edit and delete existing task. Also search by task title. This view should be sorted using the same logic as sorting in homepage, and put all the completed tasks to the bottom.

When user taps on a task, a modal dialog opens allowing them to edit all task details (brief, deadline, priority, status).

### Gantt chart page
We aggregate all the tasks together and based on the progress we recorded for each task, we generate a Gantt chart. For this page, we should look up for existing packages that renders Gantt chart. Let me know if you don't find one, and let me decide what to do.

## Storages
This is a local app, I wish it could run on all plaforms that supported by Flutter. I would like to use a local database like sqlite to save our tasks and progress record.
### Task
A task should contain these fields:
1. Task id - unique id
2. Brief - Text content user input to describe this item
3. Deadline - A date that user should complete the task before
4. Create time - When user create this item
5. Update time - Last time user edit this item
6. Priority - Importance of the item, enum value: P00, P0, P1, P2, P3, P4 (descending in importance)
7. Status - Current state of task, enum value: NOT_STARTED, IN_PROGRESS, COMPLETED

### Progress record
1. Task id - corresponding task
2. Date - date of record
3. Hours spent - Stored as a double value. Negative values represent enum options (-1: "not at all", -2: "less than 2 hours", -3: "2 to 4 hours", -4: "4-8 hours"). Positive values represent exact hours inputted by user.
