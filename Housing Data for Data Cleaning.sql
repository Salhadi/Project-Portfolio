/****** Script for SelectTopNRows command from SSMS  ******/

/*
🏠 Project Title: Nashville Housing Data Cleaning with SQL

📌 Description:
This project demonstrates my ability to clean and transform messy real estate transaction data using Microsoft SQL Server (SSMS).
The dataset includes records from Nashville, TN, and presents several data quality issues such as:
- Inconsistent date formats
- Missing property addresses
- Concatenated address fields
- Duplicate transactions
- Non-standard categorical values (e.g., 'Y'/'N' instead of 'Yes'/'No')

🎯 Key Transformations:
✔ Standardized `SaleDate` using `CONVERT()`
✔ Filled missing `PropertyAddress` values using self-join with `ISNULL()`
✔ Split address fields using `SUBSTRING()` and `PARSENAME()`
✔ Harmonized Yes/No values using `CASE WHEN`
✔ Removed duplicates with `ROW_NUMBER()` and CTE
✔ Dropped unnecessary columns to clean the final table

🛠 Tools Used:
- SQL (T-SQL)
- SSMS (SQL Server Management Studio)

This script prepares the dataset for clean reporting and downstream visualization in tools like Power BI or Excel.

🧑‍💻 Author: [Your Name or GitHub handle]
🔗 Repository: https://github.com/Salhadi/Project-Portfolio
*/






SELECT *
  FROM [Project2 Housing].[dbo].[NashvilleHousing]

  ---Sale Date Standrized
  SELECT SaleDateConverted
  FROM [Project2 Housing].[dbo].[NashvilleHousing]


     ALTER TABLE NashvilleHousing
	 Add SaleDateConverted Date;

	 UPDATE NashvilleHousing
  set SaleDateConverted = CONVERT(date,saledate)


-- Pupolate Property Address Date

  SELECT PropertyAddress
  FROM [Project2 Housing].[dbo].[NashvilleHousing]


		SELECT *
  FROM [Project2 Housing].[dbo].[NashvilleHousing]
  Where PropertyAddress is null 

	

		SELECT *
  FROM [Project2 Housing].[dbo].[NashvilleHousing]
  --Where PropertyAddress is null 
  order by ParcelID
  
  --SO,  

  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
  FROM [Project2 Housing].[dbo].[NashvilleHousing] a
  Join [Project2 Housing].[dbo].[NashvilleHousing] b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
  Where a.PropertyAddress is null

  Update a
  SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
  FROM [Project2 Housing].[dbo].[NashvilleHousing] a
  Join [Project2 Housing].[dbo].[NashvilleHousing] b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
  WHERE a.PropertyAddress is null


-- Breaking out Address ito indivisual column (Address, City, State)

  SELECT PropertyAddress
  FROM [Project2 Housing].[dbo].[NashvilleHousing]
  --Where PropertyAddress is null 
  --order by ParcelID 

		-- Using substring>> 
Select
SUBSTRING(PropertyAddress, 1, Charindex(',', propertyaddress) -1) AS Address -- This -1 command to show the string before the ','
, SUBSTRING(PropertyAddress, Charindex(',', propertyaddress) +1, LEN(propertyAddress)) AS City -- This +1 command to remove the coma from the begining 
FROM [Project2 Housing].[dbo].[NashvilleHousing]

-- To Create new columns
 ALTER TABLE NashvilleHousing
	 Add PropertSplitAddress Nvarchar(255);

	 UPDATE NashvilleHousing
  set PropertSplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', propertyaddress) -1) 

  ALTER TABLE NashvilleHousing
	 Add PropertSplitCity Nvarchar(255);

	 UPDATE NashvilleHousing
  set PropertSplitCity = SUBSTRING(PropertyAddress, Charindex(',', propertyaddress) +1, LEN(propertyAddress)) 

 --Split using PARSNAME 

  SELECT
  PARSENAME(Replace(owneraddress,',','.'), 3)
  , PARSENAME(Replace(owneraddress,',','.'), 2)
  , PARSENAME(Replace(owneraddress,',','.'), 1)
 FROM [Project2 Housing].[dbo].[NashvilleHousing]


  ALTER TABLE NashvilleHousing
	 Add OwnerSplitAddress Nvarchar(255);

	 UPDATE NashvilleHousing
  set OwnerSplitAddress = PARSENAME(Replace(owneraddress,',','.'), 3)

  ALTER TABLE NashvilleHousing
	 Add OwnerSplitCity Nvarchar(255);

	 UPDATE NashvilleHousing
  set OwnerSplitCity = PARSENAME(Replace(owneraddress,',','.'), 2)

  ALTER TABLE NashvilleHousing
	 Add OwnerSplitState Nvarchar(255);

	 UPDATE NashvilleHousing
  set OwnerSplitState = PARSENAME(Replace(owneraddress,',','.'), 1)


  -- Distinct Yes, No from Y, N

  Select 
	Distinct(SoldAsVacant), COUNT(SoldAsVacant)
  FROM [Project2 Housing].[dbo].[NashvilleHousing]
  Group By SoldAsVacant
  Order by 1		

	--USING CASE STATEMENT TO MAKE THEM JUST 2 OPTIONS YES, NO

	 Select (SoldAsVacant)

	 ,Case When(SoldAsVacant) = 'Y' Then 'Yes'
		   When(SoldAsVacant) = 'N' Then 'No'
		   Else SoldAsVacant
		   End
  FROM [Project2 Housing].[dbo].[NashvilleHousing]

	 UPDATE NashvilleHousing
  set SoldAsVacant = Case When(SoldAsVacant) = 'Y' Then 'Yes'
		   When(SoldAsVacant) = 'N' Then 'No'
		   Else SoldAsVacant
		   End


---REMOVE DUBLICATE   
Select 
  Row_Number()Over (
  Partition by 
  ParcelID,
  PropertyAddress,
  SaleDate,
  SalePrice,
  LegalReference
  Order By
  UniqueID 
   ) row_num
  FROM [Project2 Housing].[dbo].[NashvilleHousing]

  --- TO check our work

  WITH RowNumCTE As( 

  Select *,
  Row_Number()Over (
  Partition by 
  ParcelID,
  PropertyAddress,
  SaleDate,
  SalePrice,
  LegalReference
  Order By
  UniqueID 
   ) row_num
  FROM [Project2 Housing].[dbo].[NashvilleHousing]
  ) 

Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress

	--NOW >> Delete the Dublicate >>  Change Select * to Delete:


	 WITH RowNumCTE As( 

  Select *,
  Row_Number()Over (
  Partition by 
  ParcelID,
  PropertyAddress,
  SaleDate,
  SalePrice,
  LegalReference
  Order By
  UniqueID 
   ) row_num
  FROM [Project2 Housing].[dbo].[NashvilleHousing]
  ) 

Delete
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress

	

-- Delete Unused Columns

SELECT *
  FROM [Project2 Housing].[dbo].[NashvilleHousing]

  Alter Table [Project2 Housing].[dbo].[NashvilleHousing]
  Drop Column OwnerAddress, TaxDistrict, PropertyAddress

  ----------------------------------------------------------------------------------------------------------------------------
  
/* Main Points: 

Change Date formate using **Convert
Add Up new Column Using **Alter Table/ Add , OR 

   
Break data into Delimmet using **Populate / **Substring/ **Join
Break data into Delimmet using **PARSNAME

Yes, Y, No,N SET one type of Answer whiether Yes or Y USING **Distinct >> to Check answers & **Case/ When >> To change obs

Update the Table with new editing **Update/ Set


Remove Dublicate Using **Row_Number
*/
