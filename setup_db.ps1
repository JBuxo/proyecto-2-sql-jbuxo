# paths a ejecutables
$sqlite = ".\sqlite3.exe"
$db = ".\sales.db"
$schema = ".\01_schema.sql"
$dataSql = ".\02_data.sql"
$csv = ".\sales_data.csv"

# crear db y schema
Write-Output "Creating database and applying schema..."
& $sqlite $db ".read $schema"

# importar csv
Write-Output "Importing CSV data into raw_sales table..."

# Inserts
Write-Output "Running data transformation and inserts (02_data.sql)..."
& $sqlite $db ".read $dataSql"

$importCommands = @"
.mode csv
.import '$csv' raw_sales
"@

# Execute the import
$importCommands | & $sqlite $db

Write-Output "Database setup complete!"