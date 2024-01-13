
-- VIEWING THE WHOLE DATA

select * from [Nashville Housing]

-- SALEDATE COLUMN FORMATTING 

SELECT SaleDate, CONVERT(DATE,SaleDate) AS CONVERTED_DATE
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SaleDate= CONVERT(DATE,SaleDate)

select SaleDate from [Nashville Housing]

-- now we need to change the data type of the column in order for the change to be visible

ALTER TABLE [Nashville Housing] ALTER COLUMN SaleDate Date

select SaleDate from [Nashville Housing]

select * from [Nashville Housing]

--Property Address null values
-- upon close inspection we can see that for the same parcel id's are there are multiple rows but not all address are the same

select n.ParcelID,n.PropertyAddress from [Nashville Housing] n
join [Nashville Housing] na
on n.ParcelID=na.ParcelID
WHERE n.UniqueID <> na.UniqueID;

--so for the ones that are empty, lets include the address

UPDATE n
SET PropertyAddress=ISNULL(n.PropertyAddress,na.PropertyAddress)
FROM [Nashville Housing] n
join
[Nashville Housing] na
ON n.ParcelID=na.ParcelID
WHERE n.UniqueID <> na.UniqueID 
AND n.PropertyAddress is null

--checking
select PropertyAddress from [Nashville Housing] where PropertyAddress is null

--Split Property Address(Method 1)

select PropertyAddress from [Nashville Housing]

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
from [Nashville Housing]

SELECT SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from [Nashville Housing]

--Adding new columns to manage the split address

ALTER TABLE [Nashville Housing] ADD Property_Address nvarchar(250)
ALTER TABLE [Nashville Housing] ADD Property_City nvarchar(250)

--inserting into the newly created columns 

UPDATE [Nashville Housing]
SET Property_Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE [Nashville Housing]
SET Property_City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT Property_Address,Property_City FROM [Nashville Housing]

--Split Owner Address (Method 2)

SELECT OwnerAddress from [Nashville Housing]

--PARSENAME LOOKS FOR . rather than , 
--PARSENAME WORKS BACKWARDS 

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [Nashville Housing] --gives state

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),2)
from [Nashville Housing] --gives City

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)
from [Nashville Housing] --gives address

--Adding new columns to manage the split address

ALTER TABLE [Nashville Housing] ADD Owner_Address nvarchar(250)
ALTER TABLE [Nashville Housing] ADD Owner_City nvarchar(250)
ALTER TABLE [Nashville Housing] ADD Owner_State nvarchar(250)

--inserting into the newly created columns 

UPDATE [Nashville Housing]
SET Owner_Address=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE [Nashville Housing]
SET Owner_City=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE [Nashville Housing]
SET Owner_State=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Replace Y and N to Yes and No in "SoldasVacant"

SELECT DISTINCT(SoldasVacant),Count((SoldasVacant))
from [Nashville Housing]
group by SoldAsVacant

UPDATE [Nashville Housing]
SET SoldasVacant= CASE WHEN SoldasVacant='Y' THEN 'Yes'
				  WHEN SoldasVacant='N' THEN 'No'
				  ELSE SoldasVacant					-- important to give this so as to keep the right ones unchanged
				  END 
--Remove Duplicates

select * from [Nashville Housing]

--CREATING A COMMON TABLE EXPRESSION/ TEMP TABLE 
--The PARTITION BY clause specifies the columns based on which the rows should be grouped into partitions
--ROW_NUMBER() assigns a unique number to each row within a partition

-- identifies and retrieves rows from the [Nashville Housing] table where there are duplicates based on the specified columns

WITH RowCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM [Nashville Housing]
)
Select *
From RowCTE
Where row_num > 1
Order by PropertyAddress

--deleting the duplicate rows

WITH RowCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM [Nashville Housing]
)
delete 
From RowCTE
Where row_num > 1

--Delete not required columns

select * from [Nashville Housing]

ALTER TABLE [Nashville Housing]
DROP COLUMN PropertyAddress,OwnerAddress 

select * from [Nashville Housing]

