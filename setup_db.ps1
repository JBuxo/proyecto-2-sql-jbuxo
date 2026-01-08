# Path to SQLite executable (relative to current folder)
$sqlite = ".\sqlite3.exe"
$db = ".\sales.db"
$schema = ".\01_schema.sql"
$csv = ".\raw_sales.csv"

# crear db y schema
Write-Output "Creating database and applying schema..."
& $sqlite $db ".read $schema"

# importar csv
Write-Output "Importing CSV data into raw_sales table..."


$importCommands = @"
.mode csv
.import '$csv' raw_sales
"@

# Execute the import
$importCommands | & $sqlite $db

Write-Output "Database setup complete!"