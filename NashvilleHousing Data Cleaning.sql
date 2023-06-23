-- Cleaning Data in SQL Queries
SELECT *
FROM housing

-------------------------------------------------------
--Populate Property Address data
Select *
From housing
--Where property address is NULL
order by ParcelID
--in the data we can see the parcelID and the address associated with it
--Using the parcelID, the missing address would have the same ID
--Need to populate them together

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing a
JOIN housing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL
-- This shows the null address 
--New column showing the address that is needed for the null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing a
JOIN housing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL
-- Updating the column to replace the null with addresses

-----------------------------------------------------------------
-- Breaking out Address into individual columns (Address, city, state)
Select PropertyAddress
From housing
--Where property address is NULL
order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM housing
--Extracting substring from PropertyAddress
--To extract information before and asfter the comma determined the the CHARINDEX
--Both asssigned the name Address

ALTER TABLE housing 
Add PropertySplitAddress Nvarchar(255);

UPDATE housing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE housing
Add PropertySplitCity Nvarchar(255);

Update housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
FROM housing
-- At the end of the table, two new columns have been made
--PropertyAddress and PropertyCity both been split and placed into their respected columns

SELECT OwnerAddress
From housing
-- This now has the address, city and state which needs to be seperated
--Using parsename to seperate

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From housing

ALTER TABLE housing 
Add OwnerSplitAddress Nvarchar(255);

UPDATE housing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE housing
Add OwnerSplitCity Nvarchar(255);

Update housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE housing
Add OwnerSplitState Nvarchar(255);

Update housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM housing

-----------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant)
From housing
-- this shows all the values in the columns  

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From housing
Group by SoldAsVacant

SELECT SoldAsVacant
, CASE when SoldAsVacant = '0' Then 'No'
when SoldAsVacant = '1' Then 'Yes'
Else CAST(SoldAsVacant as varchar(10))
END as SoldAsVacantString
FROM housing

ALTER TABLE housing
Add SoldAsVacantString nvarchar(255);

UPDATE housing
SET SoldAsVacantString= CASE 
when SoldAsVacant = 0 Then 'No'
when SoldAsVacant = 1 Then 'Yes'
Else CAST(SoldAsVacant as varchar(255))
END 


SELECT *
From housing

----------------------------------------------------------------------
--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
FROM housing
--order by ParcelID
)

SELECT *
From RowNumCTE
Where row_num > 1
order by PropertyAddress

DELETE
FROM RowNumCTE
where row_num >1
--Deleting rows from the CTE where the value of the row_num is greater than 1
--Will remove all but the first row for each unique combination in the partioning columns

select *
From housing

----------------------------------------------------------------
--Delete Unused Columns
 SELECT *
 FROM housing

 ALTER TABLE housing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE housing
 DROP COLUMN SaleDate