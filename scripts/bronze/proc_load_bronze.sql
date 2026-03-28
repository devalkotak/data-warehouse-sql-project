CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY

        PRINT 'loading bronze layer...';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_cust_info;
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\sql\dwh_project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'crm_cust_info loaded - ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 's';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\sql\dwh_project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'crm_prd_info loaded - ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 's';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\sql\dwh_project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'crm_sales_details loaded - ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 's';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\sql\dwh_project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'erp_loc_a101 loaded - ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 's';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\sql\dwh_project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'erp_cust_az12 loaded - ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 's';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\sql\dwh_project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'erp_px_cat_g1v2 loaded - ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 's';

        PRINT 'bronze layer done';

    END TRY
    BEGIN CATCH
        PRINT 'something went wrong loading bronze';
        PRINT ERROR_MESSAGE();
    END CATCH
END
