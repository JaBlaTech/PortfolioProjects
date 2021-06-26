/*

Cleaning data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing


-- Standardizing date format


Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)


Alter Table NashvilleHousing
Add SaleDateConverted Date;


UPDATE NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


-- Populate property address data
-- We can find out that every address has it`s own ParcelID
-- and it is going to be helpfull with NULL values


Select *
From PortfolioProject..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID


Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID	
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null


Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID	
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null


UPDATE a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID	
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null


-- Breaking out address into individual columns (Address, City, State)


Select PropertyAddress
From PortfolioProject..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


UPDATE NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);


UPDATE NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select *
From PortfolioProject..NashvilleHousing


Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
, ParcelID
From PortfolioProject..NashvilleHousing
order by 4


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);


UPDATE NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);


UPDATE NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);


UPDATE NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


Select *
From PortfolioProject..NashvilleHousing
order by 2


-- Changing Y and N to Yes and No in "Sold as Vacant" field.


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'	
	   else SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'	
	   else SoldAsVacant
	   END


-- Removing duplicates


With RowNumCTE as(
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1


Select *
From PortfolioProject..NashvilleHousing


--Delete unused columns


Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, Propertyaddress, SaleDate

