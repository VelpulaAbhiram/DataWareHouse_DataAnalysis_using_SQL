--Explore All Objects in the Database
Select *from INFORMATION_SCHEMA.TABLES


--Explore All Column in the Database
Select* From INFORMATION_SCHEMA.COLUMNS
--To select something particular data  column use where clause
where TABLE_NAME ='dim_customers'
