Select *
From PortfolioProject..NashvilleHousing

--Cleaning Data on SQL


--Standardize Date Format

Select SaleDate2, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = CONVERT(Date,SaleDate)

--Run Alter Table, then Update, then Run the Select with newly created table



--Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is Null



Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID
--while checking the data, you notice that if it has the same ParcelID then it has the same property address


--need to self join the table 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) --ISNULL does that if the first value is null then it populates it with the second value in that parenthesis
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL


--Breaking out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing


--using a substring and a character or tri index

Select
SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing


--remove the actual comma from the text value by adding -1
Select
SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress) -1) as Address
From PortfolioProject..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CharIndex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

--you can't separate 2 values from a single column, you have to create 2 new columns

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CharIndex(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing


--Use Parse Name

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1) --Parsename does things backwards
From PortfolioProject..NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1) 
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1) 


Select *
From PortfolioProject..NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant)
From PortfolioProject..NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


--by using a case statement

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2



--Remove Duplicates (although it's not standard practice to delete or remove data from the database)

--Find the duplicates first

Select *, 
--use row numbers, can only use rank
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
Order By ParcelID

--then put in in a CTE

WITH RowNumCTE AS(
Select *, 
--use row numbers, can only use rank
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)

Select *
From RowNumCTE
Where row_num > 1



WITH RowNumCTE AS(
Select *, 
--use row numbers, can only use rank
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)

DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


WITH RowNumCTE AS(
Select *, 
--use row numbers, can only use rank
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order By ParcelID
)

Select *
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns (you don't do this on the raw data that you import, generally-speaking)

Select *
From PortfolioProject..NashvilleHousing

--deleting the original owner addresses, etc


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select *
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

Select *
From PortfolioProject..NashvilleHousing



