pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

// Compound Helpers
interface CTokenInterface {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function balanceOf(address owner) external view returns (uint256 balance);
}

interface CETHInterface {
    function mint() external payable;
    function repayBorrow() external payable;
    // function repayBorrowBehalf(address borrower) external payable;
    // function liquidateBorrow(address borrower, address cTokenCollateral) external payable;
}

interface InstaMapping {
    function cTokenMapping(address) external view returns (address);
    function gemJoinMapping(bytes32) external view returns (address);
}

interface ComptrollerInterface {
    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    // function exitMarket(address cTokenAddress) external returns (uint);
    // function getAssetsIn(address account) external view returns (address[] memory);
    // function getAccountLiquidity(address account) external view returns (uint, uint, uint);
}
// End Compound Helpers

// Aave v1 Helpers
interface AaveV1Interface {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external payable;
    function redeemUnderlying(
        address _reserve,
        address payable _user,
        uint256 _amount,
        uint256 _aTokenBalanceAfterRedeem
    ) external;
    
    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;
    function getUserReserveData(address _reserve, address _user) external view returns (
        uint256 currentATokenBalance,
        uint256 currentBorrowBalance,
        uint256 principalBorrowBalance,
        uint256 borrowRateMode,
        uint256 borrowRate,
        uint256 liquidityRate,
        uint256 originationFee,
        uint256 variableBorrowIndex,
        uint256 lastUpdateTimestamp,
        bool usageAsCollateralEnabled
    );
    function borrow(address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode) external;
    function repay(address _reserve, uint256 _amount, address payable _onBehalfOf) external payable;
}

interface AaveV1ProviderInterface {
    function getLendingPool() external view returns (address);
    function getLendingPoolCore() external view returns (address);
}

interface AaveV1CoreInterface {
    function getReserveATokenAddress(address _reserve) external view returns (address);
}

interface ATokenV1Interface {
    function redeem(uint256 _amount) external;
    function balanceOf(address _user) external view returns(uint256);
    function principalBalanceOf(address _user) external view returns(uint256);

    function allowance(address, address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}
// End Aave v1 Helpers

// Aave v2 Helpers
interface AaveV2Interface {
    function deposit(address _asset, uint256 _amount, address _onBehalfOf, uint16 _referralCode) external;
    function withdraw(address _asset, uint256 _amount, address _to) external;
    function borrow(
        address _asset,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode,
        address _onBehalfOf
    ) external;
    function repay(address _asset, uint256 _amount, uint256 _rateMode, address _onBehalfOf) external;
    function setUserUseReserveAsCollateral(address _asset, bool _useAsCollateral) external;
    function getUserAccountData(address user) external view returns (
        uint256 totalCollateralETH,
        uint256 totalDebtETH,
        uint256 availableBorrowsETH,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    );
}

interface AaveV2LendingPoolProviderInterface {
    function getLendingPool() external view returns (address);
}

// Aave Protocol Data Provider
interface AaveV2DataProviderInterface {
    function getUserReserveData(address _asset, address _user) external view returns (
        uint256 currentATokenBalance,
        uint256 currentStableDebt,
        uint256 currentVariableDebt,
        uint256 principalStableDebt,
        uint256 scaledVariableDebt,
        uint256 stableBorrowRate,
        uint256 liquidityRate,
        uint40 stableRateLastUpdated,
        bool usageAsCollateralEnabled
    );
}
// End Aave v2 Helpers

// MakerDAO Helpers
interface ManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function last(address) external view returns (uint);
    function count(address) external view returns (uint);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint);
    function give(uint, address) external;
    function frob(uint, int, int) external;
    function flux(uint, address, uint) external;
    function move(uint, address, uint) external;
}

interface VatLike {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);
    function frob(
        bytes32,
        address,
        address,
        address,
        int,
        int
    ) external;
    function hope(address) external;
    function move(address, address, uint) external;
    function gem(bytes32, address) external view returns (uint);
}

interface TokenJoinInterface {
    function dec() external returns (uint);
    function gem() external returns (TokenInterface);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface DaiJoinInterface {
    function vat() external returns (VatLike);
    function dai() external returns (TokenInterface);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint);
}
// End MakerDAO Helpers

contract DSMath {

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = mul(_amt, 10 ** (18 - _dec));
    }

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = (_amt / 10 ** (18 - _dec));
    }

}

contract Helpers is DSMath {

    using SafeERC20 for IERC20;

    enum Protocol {
        Aave,
        AaveV2,
        Compound
    }

    address payable constant feeCollector = 0xb1DC62EC38E6E3857a887210C38418E4A17Da5B2;

    /**
     * @dev Return ethereum address
     */
    function getEthAddr() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }

    /**
     * @dev Return Weth address
    */
    function getWethAddr() internal pure returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet WETH Address
        // return 0xd0A1E359811322d97991E03f863a0C30C2cF029C; // Kovan WETH Address
    }

    /**
     * @dev Connector Details.
    */
    function connectorID() public pure returns(uint _type, uint _id) {
        (_type, _id) = (1, 72);
    }

    /**
     * @dev Return InstaDApp Mapping Address
     */
    function getMappingAddr() internal pure returns (address) {
        return 0xe81F70Cc7C0D46e12d70efc60607F16bbD617E88; // InstaMapping Address
    }

    /**
     * @dev Return Compound Comptroller Address
     */
    function getComptrollerAddress() internal pure returns (address) {
        return 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    }

    /**
     * @dev Return Maker MCD DAI_Join Address.
    */
    function getMcdDaiJoin() internal pure returns (address) {
        return 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    }

    /**
     * @dev Return Maker MCD Manager Address.
    */
    function getMcdManager() internal pure returns (address) {
        return 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    }

    /**
     * @dev Return Maker MCD DAI Address.
    */
    function getMcdDai() internal pure returns (address) {
        return 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    /**
     * @dev Return Maker MCD Jug Address.
    */
    function getMcdJug() internal pure returns (address) {
        return 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    }

    /**
     * @dev get Aave Provider
    */
    function getAaveProvider() internal pure returns (AaveV1ProviderInterface) {
        return AaveV1ProviderInterface(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8); //mainnet
        // return AaveV1ProviderInterface(0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5); //kovan
    }

    /**
     * @dev get Aave Lending Pool Provider
    */
    function getAaveV2Provider() internal pure returns (AaveV2LendingPoolProviderInterface) {
        return AaveV2LendingPoolProviderInterface(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5); //mainnet
        // return AaveV2LendingPoolProviderInterface(0x652B2937Efd0B5beA1c8d54293FC1289672AFC6b); //kovan
    }

    /**
     * @dev get Aave Protocol Data Provider
    */
    function getAaveV2DataProvider() internal pure returns (AaveV2DataProviderInterface) {
        return AaveV2DataProviderInterface(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d); //mainnet
        // return AaveV2DataProviderInterface(0x744C1aaA95232EeF8A9994C4E0b3a89659D9AB79); //kovan
    }

    /**
     * @dev get Referral Code
    */
    function getReferralCode() internal pure returns (uint16) {
        return 3228;
    }

    function getWithdrawBalance(AaveV1Interface aave, address token) internal view returns (uint bal) {
        (bal, , , , , , , , , ) = aave.getUserReserveData(token, address(this));
    }

    function getPaybackBalance(AaveV1Interface aave, address token) internal view returns (uint bal, uint fee) {
        (, bal, , , , , fee, , , ) = aave.getUserReserveData(token, address(this));
    }

    function getTotalBorrowBalance(AaveV1Interface aave, address token) internal view returns (uint amt) {
        (, uint bal, , , , , uint fee, , , ) = aave.getUserReserveData(token, address(this));
        amt = add(bal, fee);
    }

    function getWithdrawBalanceV2(AaveV2DataProviderInterface aaveData, address token) internal view returns (uint bal) {
        (bal, , , , , , , , ) = aaveData.getUserReserveData(token, address(this));
    }

    function getPaybackBalanceV2(AaveV2DataProviderInterface aaveData, address token, uint rateMode) internal view returns (uint bal) {
        if (rateMode == 1) {
            (, bal, , , , , , , ) = aaveData.getUserReserveData(token, address(this));
        } else {
            (, , bal, , , , , , ) = aaveData.getUserReserveData(token, address(this));
        }
    }

    function getIsColl(AaveV1Interface aave, address token) internal view returns (bool isCol) {
        (, , , , , , , , , isCol) = aave.getUserReserveData(token, address(this));
    }

    function getIsCollV2(AaveV2DataProviderInterface aaveData, address token) internal view returns (bool isCol) {
        (, , , , , , , , isCol) = aaveData.getUserReserveData(token, address(this));
    }

    /**
     * @dev Get Vault's ilk.
    */
    function getVaultData(ManagerLike managerContract, uint vault) internal view returns (bytes32 ilk, address urn) {
        ilk = managerContract.ilks(vault);
        urn = managerContract.urns(vault);
    }

    /**
     * @dev Get Vault Debt Amount.
    */
    function _getVaultDebt(
        address vat,
        bytes32 ilk,
        address urn
    ) internal view returns (uint wad) {
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);
        uint dai = VatLike(vat).dai(urn);

        uint rad = sub(mul(art, rate), dai);
        wad = rad / RAY;

        wad = mul(wad, RAY) < rad ? wad + 1 : wad;
    }

    /**
     * @dev Get Payback Amount.
    */
    function _getWipeAmt(
        address vat,
        uint amt,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart)
    {
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);
        dart = toInt(amt / rate);
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    /**
     * @dev Convert String to bytes32.
    */
    function stringToBytes32(string memory str) internal pure returns (bytes32 result) {
        require(bytes(str).length != 0, "string-empty");
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            result := mload(add(str, 32))
        }
    }

    /**
     * @dev Get vault ID. If `vault` is 0, get last opened vault.
    */
    function getVault(ManagerLike managerContract, uint vault) internal view returns (uint _vault) {
        if (vault == 0) {
            require(managerContract.count(address(this)) > 0, "no-vault-opened");
            _vault = managerContract.last(address(this));
        } else {
            _vault = vault;
        }
    }

    /**
     * @dev Get Borrow Amount [MakerDAO]
    */
    function _getBorrowAmt(
        address vat,
        address urn,
        bytes32 ilk,
        uint amt
    ) internal returns (int dart)
    {
        address jug = getMcdJug();
        uint rate = JugLike(jug).drip(ilk);
        uint dai = VatLike(vat).dai(urn);
        if (dai < mul(amt, RAY)) {
            dart = toInt(sub(mul(amt, RAY), dai) / rate);
            dart = mul(uint(dart), rate) < mul(amt, RAY) ? dart + 1 : dart;
        }
    }

    function convertEthToWeth(bool isEth, TokenInterface token, uint amount) internal {
        if(isEth) token.deposit.value(amount)();
    }

    function convertWethToEth(bool isEth, TokenInterface token, uint amount) internal {
       if(isEth) {
            token.approve(address(token), amount);
            token.withdraw(amount);
        }
    }

    function getMaxBorrow(Protocol target, address token, uint rateMode) internal returns (uint amt) {
        AaveV1Interface aaveV1 = AaveV1Interface(getAaveProvider().getLendingPool());
        AaveV2DataProviderInterface aaveData = getAaveV2DataProvider();

        if (target == Protocol.Aave) {
            (uint _amt, uint _fee) = getPaybackBalance(aaveV1, token);
            amt = _amt + _fee;
        } else if (target == Protocol.AaveV2) {
            amt = getPaybackBalanceV2(aaveData, token, rateMode);
        } else if (target == Protocol.Compound) {
            address cToken = InstaMapping(getMappingAddr()).cTokenMapping(token);
            amt = CTokenInterface(cToken).borrowBalanceCurrent(address(this));
        }
    }

    function transferFees(address token, uint feeAmt) internal {
        if (feeAmt > 0) {
            if (token == getEthAddr()) {
                feeCollector.transfer(feeAmt);
            } else {
                IERC20(token).safeTransfer(feeCollector, feeAmt);
            }
        }
    }

    function calculateFee(uint256 amount, uint256 fee, bool toAdd) internal pure returns(uint feeAmount, uint _amount){
        feeAmount = wmul(amount, fee);
        _amount = toAdd ? add(amount, feeAmount) : sub(amount, feeAmount);
    }

    function getTokenInterfaces(uint length, address[] memory tokens) internal pure returns (TokenInterface[] memory) {
        TokenInterface[] memory _tokens = new TokenInterface[](length);
        for (uint i = 0; i < length; i++) {
            if (tokens[i] ==  getEthAddr()) {
                _tokens[i] = TokenInterface(getWethAddr());
            } else {
                _tokens[i] = TokenInterface(tokens[i]);
            }
        }
        return _tokens;
    }

    function getCtokenInterfaces(uint length, address[] memory tokens) internal view returns (CTokenInterface[] memory) {
        CTokenInterface[] memory _ctokens = new CTokenInterface[](length);
        for (uint i = 0; i < length; i++) {
            address _cToken = InstaMapping(getMappingAddr()).cTokenMapping(tokens[i]);
            _ctokens[i] = CTokenInterface(_cToken);
        }
        return _ctokens;
    }
}

contract CompoundHelpers is Helpers {

    struct CompoundBorrowData {
        uint length;
        uint fee;
        Protocol target;
        CTokenInterface[] ctokens;
        TokenInterface[] tokens;
        uint[] amts;
        uint[] rateModes;
    }

    function _compEnterMarkets(uint length, CTokenInterface[] memory ctokens) internal {
        ComptrollerInterface troller = ComptrollerInterface(getComptrollerAddress());
        address[] memory _cTokens = new address[](length);

        for (uint i = 0; i < length; i++) {
            _cTokens[i] = address(ctokens[i]);
        }
        troller.enterMarkets(_cTokens);
    }

    function _compBorrowOne(
        uint fee,
        CTokenInterface ctoken,
        TokenInterface token,
        uint amt,
        Protocol target,
        uint rateMode
    ) internal returns (uint) {
        if (amt > 0) {
            address _token = address(token) == getWethAddr() ? getEthAddr() : address(token);

            if (amt == uint(-1)) {
                amt = getMaxBorrow(target, address(token), rateMode);
            }

            (uint feeAmt, uint _amt) = calculateFee(amt, fee, true);

            require(ctoken.borrow(_amt) == 0, "borrow-failed-collateral?");
            transferFees(_token, feeAmt);
        }
        return amt;
    }

    function _compBorrow(
        CompoundBorrowData memory data
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](data.length);
        for (uint i = 0; i < data.length; i++) {
            finalAmts[i] = _compBorrowOne(
                data.fee, 
                data.ctokens[i], 
                data.tokens[i], 
                data.amts[i], 
                data.target, 
                data.rateModes[i]
            );
        }
        return finalAmts;
    }

    function _compDepositOne(uint fee, CTokenInterface ctoken, TokenInterface token, uint amt) internal {
        if (amt > 0) {
            address _token = address(token) == getWethAddr() ? getEthAddr() : address(token);

            (uint feeAmt, uint _amt) = calculateFee(amt, fee, false);

            if (_token != getEthAddr()) {
                token.approve(address(ctoken), _amt);
                require(ctoken.mint(_amt) == 0, "deposit-failed");
            } else {
                CETHInterface(address(ctoken)).mint.value(_amt)();
            }
            transferFees(_token, feeAmt);
        }
    }

    function _compDeposit(
        uint length,
        uint fee,
        CTokenInterface[] memory ctokens,
        TokenInterface[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _compDepositOne(fee, ctokens[i], tokens[i], amts[i]);
        }
    }

    function _compWithdrawOne(CTokenInterface ctoken, TokenInterface token, uint amt) internal returns (uint) {
        if (amt > 0) {
            if (amt == uint(-1)) {
                bool isEth = address(token) == getWethAddr();
                uint initalBal = isEth ? address(this).balance : token.balanceOf(address(this));
                require(ctoken.redeem(ctoken.balanceOf(address(this))) == 0, "withdraw-failed");
                uint finalBal = isEth ? address(this).balance : token.balanceOf(address(this));
                amt = finalBal - initalBal;
            } else {
                require(ctoken.redeemUnderlying(amt) == 0, "withdraw-failed");
            }
        }
        return amt;
    }

    function _compWithdraw(
        uint length,
        CTokenInterface[] memory ctokens,
        TokenInterface[] memory tokens,
        uint[] memory amts
    ) internal returns(uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _compWithdrawOne(ctokens[i], tokens[i], amts[i]);
        }
        return finalAmts;
    }

    function _compPaybackOne(CTokenInterface ctoken, TokenInterface token, uint amt) internal returns (uint) {
        if (amt > 0) {
            if (amt == uint(-1)) {
                amt = ctoken.borrowBalanceCurrent(address(this));
            }
            if (address(token) != getWethAddr()) {
                token.approve(address(ctoken), amt);
                require(ctoken.repayBorrow(amt) == 0, "repay-failed.");
            } else {
                CETHInterface(address(ctoken)).repayBorrow.value(amt)();
            }
        }
        return amt;
    }

    function _compPayback(
        uint length,
        CTokenInterface[] memory ctokens,
        TokenInterface[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _compPaybackOne(ctokens[i], tokens[i], amts[i]);
        }
    }
}

contract AaveV1Helpers is CompoundHelpers {

    struct AaveV1BorrowData {
        AaveV1Interface aave;
        uint length;
        uint fee;
        Protocol target;
        TokenInterface[] tokens;
        uint[] amts;
        uint[] borrowRateModes;
        uint[] paybackRateModes;
    }

    function _aaveV1BorrowOne(
        AaveV1Interface aave,
        uint fee,
        Protocol target,
        TokenInterface token,
        uint amt,
        uint borrowRateMode,
        uint paybackRateMode
    ) internal returns (uint) {
        if (amt > 0) {

            address _token = address(token) == getWethAddr() ? getEthAddr() : address(token);

            if (amt == uint(-1)) {
                amt = getMaxBorrow(target, address(token), paybackRateMode);
            }

            (uint feeAmt, uint _amt) = calculateFee(amt, fee, true);

            aave.borrow(_token, _amt, borrowRateMode, getReferralCode());
            transferFees(_token, feeAmt);
        }
        return amt;
    }

    function _aaveV1Borrow(
        AaveV1BorrowData memory data
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](data.length);
        for (uint i = 0; i < data.length; i++) {
            finalAmts[i] = _aaveV1BorrowOne(
                data.aave,
                data.fee,
                data.target,
                data.tokens[i],
                data.amts[i],
                data.borrowRateModes[i],
                data.paybackRateModes[i]
            );
        }
        return finalAmts;
    }

    function _aaveV1DepositOne(
        AaveV1Interface aave,
        AaveV1CoreInterface aaveCore,
        uint fee,
        TokenInterface token,
        uint amt
    ) internal {
        if (amt > 0) {
            uint ethAmt;
            (uint feeAmt, uint _amt) = calculateFee(amt, fee, false);

            bool isEth = address(token) == getWethAddr();

            address _token = isEth ? getEthAddr() : address(token);

            if (isEth) {
                ethAmt = _amt;
            } else {
                token.approve(address(aaveCore), _amt);
            }

            transferFees(_token, feeAmt);

            aave.deposit.value(ethAmt)(_token, _amt, getReferralCode());

            if (!getIsColl(aave, _token))
                aave.setUserUseReserveAsCollateral(_token, true);
        }
    }

    function _aaveV1Deposit(
        AaveV1Interface aave,
        AaveV1CoreInterface aaveCore,
        uint length,
        uint fee,
        TokenInterface[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _aaveV1DepositOne(aave, aaveCore, fee, tokens[i], amts[i]);
        }
    }

    function _aaveV1WithdrawOne(
        AaveV1Interface aave,
        AaveV1CoreInterface aaveCore,
        TokenInterface token,
        uint amt
    ) internal returns (uint) {
        if (amt > 0) {
            address _token = address(token) == getWethAddr() ? getEthAddr() : address(token);
            ATokenV1Interface atoken = ATokenV1Interface(aaveCore.getReserveATokenAddress(_token));
            if (amt == uint(-1)) {
                amt = getWithdrawBalance(aave, _token);
            }
            atoken.redeem(amt);
        }
        return amt;
    }

    function _aaveV1Withdraw(
        AaveV1Interface aave,
        AaveV1CoreInterface aaveCore,
        uint length,
        TokenInterface[] memory tokens,
        uint[] memory amts
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _aaveV1WithdrawOne(aave, aaveCore, tokens[i], amts[i]);
        }
        return finalAmts;
    }

    function _aaveV1PaybackOne(
        AaveV1Interface aave,
        AaveV1CoreInterface aaveCore,
        TokenInterface token,
        uint amt
    ) internal returns (uint) {
        if (amt > 0) {
            uint ethAmt;

            bool isEth = address(token) == getWethAddr();

            address _token = isEth ? getEthAddr() : address(token);

            if (amt == uint(-1)) {
                (uint _amt, uint _fee) = getPaybackBalance(aave, _token);
                amt = _amt + _fee;
            }

            if (isEth) {
                ethAmt = amt;
            } else {
                token.approve(address(aaveCore), amt);
            }

            aave.repay.value(ethAmt)(_token, amt, payable(address(this)));
        }
        return amt;
    }

    function _aaveV1Payback(
        AaveV1Interface aave,
        AaveV1CoreInterface aaveCore,
        uint length,
        TokenInterface[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _aaveV1PaybackOne(aave, aaveCore, tokens[i], amts[i]);
        }
    }
}

contract AaveV2Helpers is AaveV1Helpers {

    struct AaveV2BorrowData {
        AaveV2Interface aave;
        uint length;
        uint fee;
        Protocol target;
        TokenInterface[] tokens;
        uint[] amts;
        uint[] rateModes;
    }

    function _aaveV2BorrowOne(
        AaveV2Interface aave,
        uint fee,
        Protocol target,
        TokenInterface token,
        uint amt,
        uint rateMode
    ) internal returns (uint) {
        if (amt > 0) {
            address _token = address(token) == getWethAddr() ? getEthAddr() : address(token);

            if (amt == uint(-1)) {
                amt = getMaxBorrow(target, _token, rateMode);
            }

            (uint feeAmt, uint _amt) = calculateFee(amt, fee, true);

            bool isEth = address(token) == getWethAddr();

            aave.borrow(address(token), _amt, rateMode, getReferralCode(), address(this));
            convertWethToEth(isEth, token, amt);

            transferFees(_token, feeAmt);
        }
        return amt;
    }

    function _aaveV2Borrow(
        AaveV2BorrowData memory data
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](data.length);
        for (uint i = 0; i < data.length; i++) {
            finalAmts[i] = _aaveV2BorrowOne(
                data.aave,
                data.fee,
                data.target,
                data.tokens[i],
                data.amts[i],
                data.rateModes[i]
            );
        }
        return finalAmts;
    }

    function _aaveV2DepositOne(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        uint fee,
        TokenInterface token,
        uint amt
    ) internal {
        if (amt > 0) {
            (uint feeAmt, uint _amt) = calculateFee(amt, fee, false);

            bool isEth = address(token) == getWethAddr();
            address _token = isEth ? getEthAddr() : address(token);

            transferFees(_token, feeAmt);

            convertEthToWeth(isEth, token, _amt);

            token.approve(address(aave), _amt);

            aave.deposit(address(token), _amt, address(this), getReferralCode());

            if (!getIsCollV2(aaveData, address(token))) {
                aave.setUserUseReserveAsCollateral(address(token), true);
            }
        }
    }

    function _aaveV2Deposit(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        uint length,
        uint fee,
        TokenInterface[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _aaveV2DepositOne(aave, aaveData, fee, tokens[i], amts[i]);
        }
    }

    function _aaveV2WithdrawOne(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        TokenInterface token,
        uint amt
    ) internal returns (uint _amt) {
        if (amt > 0) {
            bool isEth = address(token) == getWethAddr();

            aave.withdraw(address(token), amt, address(this));

            _amt = amt == uint(-1) ? getWithdrawBalanceV2(aaveData, address(token)) : amt;

            convertWethToEth(isEth, token, _amt);
        }
    }

    function _aaveV2Withdraw(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        uint length,
        TokenInterface[] memory tokens,
        uint[] memory amts
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _aaveV2WithdrawOne(aave, aaveData, tokens[i], amts[i]);
        }
        return finalAmts;
    }

    function _aaveV2PaybackOne(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        TokenInterface token,
        uint amt,
        uint rateMode
    ) internal returns (uint _amt) {
        if (amt > 0) {
            bool isEth = address(token) == getWethAddr();

            _amt = amt == uint(-1) ? getPaybackBalanceV2(aaveData, address(token), rateMode) : amt;

            convertEthToWeth(isEth, token, _amt);

            token.approve(address(aave), _amt);

            aave.repay(address(token), _amt, rateMode, address(this));
        }
    }

    function _aaveV2Payback(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        uint length,
        TokenInterface[] memory tokens,
        uint[] memory amts,
        uint[] memory rateModes
    ) internal {
        for (uint i = 0; i < length; i++) {
            _aaveV2PaybackOne(aave, aaveData, tokens[i], amts[i], rateModes[i]);
        }
    }
}

contract MakerHelpers is AaveV2Helpers {

    struct MakerData {
        uint _vault;
        address colAddr;
        address daiJoin;
        TokenJoinInterface tokenJoinContract;
        VatLike vatContract;
        TokenInterface tokenContract;
        DaiJoinInterface daiJoinContract;
    }

    function _makerOpen(string memory colType) internal {
        bytes32 ilk = stringToBytes32(colType);
        require(InstaMapping(getMappingAddr()).gemJoinMapping(ilk) != address(0), "wrong-col-type");
        ManagerLike(getMcdManager()).open(ilk, address(this));
    }

    function _makerDepositAndBorrow(
        uint vault,
        uint collateralAmt,
        uint debtAmt,
        uint collateralFee,
        uint debtFee
    ) internal {
        (uint collateralFeeAmt, uint _collateralAmt) = calculateFee(collateralAmt, collateralFee, false);

        (uint debtFeeAmt, uint _debtAmt) = calculateFee(debtAmt, debtFee, true);

        MakerData memory makerData;

        ManagerLike managerContract = ManagerLike(getMcdManager());

        makerData._vault = getVault(managerContract, vault);
        (bytes32 ilk, address urn) = getVaultData(managerContract, makerData._vault);

        makerData.colAddr = InstaMapping(getMappingAddr()).gemJoinMapping(ilk);
        makerData.tokenJoinContract = TokenJoinInterface(makerData.colAddr);
        makerData.tokenContract = makerData.tokenJoinContract.gem();
        makerData.daiJoin = getMcdDaiJoin();
        makerData.vatContract = VatLike(managerContract.vat());

        if (address(makerData.tokenContract) == getWethAddr()) {
            makerData.tokenContract.deposit.value(collateralAmt)();
        }

        transferFees(address(makerData.tokenContract), collateralFeeAmt);

        makerData.tokenContract.approve(address(makerData.colAddr), _collateralAmt);
        makerData.tokenJoinContract.join(urn, _collateralAmt);

        int intAmt = toInt(convertTo18(makerData.tokenJoinContract.dec(), _collateralAmt));

        int dart = _getBorrowAmt(address(makerData.vatContract), urn, ilk, _debtAmt);

        managerContract.frob(
            makerData._vault,
            intAmt,
            dart
        );

        managerContract.move(
            makerData._vault,
            address(this),
            toRad(_debtAmt)
        );

        if (makerData.vatContract.can(address(this), address(makerData.daiJoin)) == 0) {
            makerData.vatContract.hope(makerData.daiJoin);
        }

        DaiJoinInterface(makerData.daiJoin).exit(address(this), _debtAmt);

        transferFees(getMcdDai(), debtFeeAmt);
    }

    function _makerPaybackAndWithdraw(
        uint vault,
        uint withdrawAmt,
        uint paybackAmt
    ) internal returns (uint, uint) {
        ManagerLike managerContract = ManagerLike(getMcdManager());
        MakerData memory makerData;

        makerData._vault = getVault(managerContract, vault);
        (bytes32 ilk, address urn) = getVaultData(managerContract, makerData._vault);

        makerData.colAddr = InstaMapping(getMappingAddr()).gemJoinMapping(ilk);
        makerData.tokenJoinContract = TokenJoinInterface(makerData.colAddr);
        makerData.tokenContract = makerData.tokenJoinContract.gem();
        makerData.daiJoin = getMcdDaiJoin();
        makerData.vatContract = VatLike(managerContract.vat());

        uint _withdrawAmt18;
        if (withdrawAmt == uint(-1)) {
            (_withdrawAmt18,) = makerData.vatContract.urns(ilk, urn);
            withdrawAmt = convert18ToDec(makerData.tokenJoinContract.dec(), _withdrawAmt18);
        } else {
            _withdrawAmt18 = convertTo18(makerData.tokenJoinContract.dec(), withdrawAmt);
        }

        int _paybackDart;
        {
            (, uint art) = makerData.vatContract.urns(ilk, urn);
            uint _maxDebt = _getVaultDebt(address(makerData.vatContract), ilk, urn);
            _paybackDart = paybackAmt == uint(-1) ?
                -int(art) :
                _getWipeAmt(
                address(makerData.vatContract),
                makerData.vatContract.dai(urn),
                urn,
                ilk
            );

            paybackAmt = paybackAmt == uint(-1) ? _maxDebt : paybackAmt;

            require(_maxDebt >= paybackAmt, "paying-excess-debt");
        }

        makerData.daiJoinContract = DaiJoinInterface(makerData.daiJoin);
        makerData.daiJoinContract.dai().approve(makerData.daiJoin, paybackAmt);
        makerData.daiJoinContract.join(urn, paybackAmt);

        managerContract.frob(
            makerData._vault,
            -toInt(_withdrawAmt18),
            _paybackDart
        );

        managerContract.flux(
            makerData._vault,
            address(this),
            _withdrawAmt18
        );

        if (address(makerData.tokenContract) == getWethAddr()) {
            makerData.tokenJoinContract.exit(address(this), _withdrawAmt18);
            makerData.tokenContract.withdraw(_withdrawAmt18);
        } else {
            makerData.tokenJoinContract.exit(address(this), _withdrawAmt18);
        }

        return (withdrawAmt, paybackAmt);
    }
}

contract RefinanceResolver is MakerHelpers {

    struct RefinanceData {
        Protocol source;
        Protocol target;
        uint collateralFee;
        uint debtFee;
        address[] tokens;
        uint[] borrowAmts;
        uint[] withdrawAmts;
        uint[] borrowRateModes;
        uint[] paybackRateModes;
    }

    struct RefinanceMakerData {
        uint fromVaultId;
        uint toVaultId;
        Protocol source;
        Protocol target;
        uint collateralFee;
        uint debtFee;
        bool isFrom;
        string colType;
        address token;
        uint debt;
        uint collateral;
        uint borrowRateMode;
        uint paybackRateMode;
    }

    function refinance(RefinanceData calldata data) external payable {

        require(data.source != data.target, "source-and-target-unequal");

        uint length = data.tokens.length;

        require(data.borrowAmts.length == length, "length-mismatch");
        require(data.withdrawAmts.length == length, "length-mismatch");
        require(data.borrowRateModes.length == length, "length-mismatch");
        require(data.paybackRateModes.length == length, "length-mismatch");

        AaveV2Interface aaveV2 = AaveV2Interface(getAaveV2Provider().getLendingPool());
        AaveV1Interface aaveV1 = AaveV1Interface(getAaveProvider().getLendingPool());
        AaveV1CoreInterface aaveCore = AaveV1CoreInterface(getAaveProvider().getLendingPoolCore());
        AaveV2DataProviderInterface aaveData = getAaveV2DataProvider();

        uint[] memory depositAmts;
        uint[] memory paybackAmts;

        TokenInterface[] memory tokens = getTokenInterfaces(length, data.tokens);

        if (data.source == Protocol.Aave && data.target == Protocol.AaveV2) {
            AaveV2BorrowData memory _aaveV2BorrowData;

            _aaveV2BorrowData.aave = aaveV2;
            _aaveV2BorrowData.length = length;
            _aaveV2BorrowData.fee = data.debtFee;
            _aaveV2BorrowData.target = data.source;
            _aaveV2BorrowData.tokens = tokens;
            _aaveV2BorrowData.amts = data.borrowAmts;
            _aaveV2BorrowData.rateModes = data.borrowRateModes;

            paybackAmts = _aaveV2Borrow(_aaveV2BorrowData);
            _aaveV1Payback(aaveV1, aaveCore, length, tokens, paybackAmts);
            depositAmts = _aaveV1Withdraw(aaveV1, aaveCore, length, tokens, data.withdrawAmts);
            _aaveV2Deposit(aaveV2, aaveData, length, data.collateralFee, tokens, depositAmts);
        } else if (data.source == Protocol.Aave && data.target == Protocol.Compound) {
            CTokenInterface[] memory _ctokens = getCtokenInterfaces(length, data.tokens);
            _compEnterMarkets(length, _ctokens);

            CompoundBorrowData memory _compoundBorrowData;

            _compoundBorrowData.length = length;
            _compoundBorrowData.fee = data.debtFee;
            _compoundBorrowData.target = data.source;
            _compoundBorrowData.ctokens = _ctokens;
            _compoundBorrowData.tokens = tokens;
            _compoundBorrowData.amts = data.borrowAmts;
            _compoundBorrowData.rateModes = data.borrowRateModes;

            paybackAmts = _compBorrow(_compoundBorrowData);
            
            _aaveV1Payback(aaveV1, aaveCore, length, tokens, paybackAmts);
            depositAmts = _aaveV1Withdraw(aaveV1, aaveCore, length, tokens, data.withdrawAmts);
            _compDeposit(length, data.collateralFee, _ctokens, tokens, depositAmts);
        } else if (data.source == Protocol.AaveV2 && data.target == Protocol.Aave) {

            AaveV1BorrowData memory _aaveV1BorrowData;

            _aaveV1BorrowData.aave = aaveV1;
            _aaveV1BorrowData.length = length;
            _aaveV1BorrowData.fee = data.debtFee;
            _aaveV1BorrowData.target = data.source;
            _aaveV1BorrowData.tokens = tokens;
            _aaveV1BorrowData.amts = data.borrowAmts;
            _aaveV1BorrowData.borrowRateModes = data.borrowRateModes;
            _aaveV1BorrowData.paybackRateModes = data.paybackRateModes;

            paybackAmts = _aaveV1Borrow(_aaveV1BorrowData);
            _aaveV2Payback(aaveV2, aaveData, length, tokens, paybackAmts, data.paybackRateModes);
            depositAmts = _aaveV2Withdraw(aaveV2, aaveData, length, tokens, data.withdrawAmts);
            _aaveV1Deposit(aaveV1, aaveCore, length, data.collateralFee, tokens, depositAmts);
        } else if (data.source == Protocol.AaveV2 && data.target == Protocol.Compound) {
            CTokenInterface[] memory _ctokens = getCtokenInterfaces(length, data.tokens);
            _compEnterMarkets(length, _ctokens);

            {
                CompoundBorrowData memory _compoundBorrowData;

                _compoundBorrowData.length = length;
                _compoundBorrowData.fee = data.debtFee;
                _compoundBorrowData.target = data.source;
                _compoundBorrowData.ctokens = _ctokens;
                _compoundBorrowData.tokens = tokens;
                _compoundBorrowData.amts = data.borrowAmts;
                _compoundBorrowData.rateModes = data.borrowRateModes;

                paybackAmts = _compBorrow(_compoundBorrowData);
            }
            
            _aaveV2Payback(aaveV2, aaveData, length, tokens, paybackAmts, data.paybackRateModes);
            depositAmts = _aaveV2Withdraw(aaveV2, aaveData, length, tokens, data.withdrawAmts);
            _compDeposit(length, data.collateralFee, _ctokens, tokens, depositAmts);
        } else if (data.source == Protocol.Compound && data.target == Protocol.Aave) {

            AaveV1BorrowData memory _aaveV1BorrowData;

            _aaveV1BorrowData.aave = aaveV1;
            _aaveV1BorrowData.length = length;
            _aaveV1BorrowData.fee = data.debtFee;
            _aaveV1BorrowData.target = data.source;
            _aaveV1BorrowData.tokens = tokens;
            _aaveV1BorrowData.amts = data.borrowAmts;
            _aaveV1BorrowData.borrowRateModes = data.borrowRateModes;
            _aaveV1BorrowData.paybackRateModes = data.paybackRateModes;
            
            paybackAmts = _aaveV1Borrow(_aaveV1BorrowData);
            {
            CTokenInterface[] memory _ctokens = getCtokenInterfaces(length, data.tokens);
            _compPayback(length, _ctokens, tokens, paybackAmts);
            depositAmts = _compWithdraw(length, _ctokens, tokens, data.withdrawAmts);
            }
            _aaveV1Deposit(aaveV1, aaveCore, length, data.collateralFee, tokens, depositAmts);
        } else if (data.source == Protocol.Compound && data.target == Protocol.AaveV2) {
            CTokenInterface[] memory _ctokens = getCtokenInterfaces(length, data.tokens);

            AaveV2BorrowData memory _aaveV2BorrowData;

            _aaveV2BorrowData.aave = aaveV2;
            _aaveV2BorrowData.length = length;
            _aaveV2BorrowData.fee = data.debtFee;
            _aaveV2BorrowData.target = data.source;
            _aaveV2BorrowData.tokens = tokens;
            _aaveV2BorrowData.amts = data.borrowAmts;
            _aaveV2BorrowData.rateModes = data.borrowRateModes;
            
            paybackAmts = _aaveV2Borrow(_aaveV2BorrowData);
            _compPayback(length, _ctokens, tokens, paybackAmts);
            depositAmts = _compWithdraw(length, _ctokens, tokens, data.withdrawAmts);
            _aaveV2Deposit(aaveV2, aaveData, length, data.collateralFee, tokens, depositAmts);
        } else {
            revert("invalid-options");
        }
    }

    function refinanceMaker(RefinanceMakerData calldata data) external payable {

        AaveV2Interface aaveV2 = AaveV2Interface(getAaveV2Provider().getLendingPool());
        AaveV1Interface aaveV1 = AaveV1Interface(getAaveProvider().getLendingPool());
        AaveV1CoreInterface aaveCore = AaveV1CoreInterface(getAaveProvider().getLendingPoolCore());
        AaveV2DataProviderInterface aaveData = getAaveV2DataProvider();

        TokenInterface dai = TokenInterface(getMcdDai());
        TokenInterface token = TokenInterface(data.token == getEthAddr() ? getWethAddr() : data.token);

        uint depositAmt;
        uint borrowAmt;

        if (data.isFrom) {
            (depositAmt, borrowAmt) = _makerPaybackAndWithdraw(
                data.fromVaultId,
                data.collateral,
                data.debt
            );

            if (data.target == Protocol.Aave) {
                _aaveV1DepositOne(aaveV1, aaveCore, data.collateralFee, token, depositAmt);
                _aaveV1BorrowOne(aaveV1, data.debtFee, Protocol.AaveV2, dai, borrowAmt, data.borrowRateMode, 2);
            } else if (data.target == Protocol.AaveV2) {
                _aaveV2DepositOne(aaveV2, aaveData, data.collateralFee, token, depositAmt);
                _aaveV2BorrowOne(aaveV2, data.debtFee, Protocol.AaveV2, dai, borrowAmt, data.borrowRateMode);
            } else if (data.target == Protocol.Compound) {
                address[] memory tokens = new address[](2);
                tokens[0] = address(dai);
                tokens[1] = data.token;

                CTokenInterface[] memory _ctokens = getCtokenInterfaces(2, tokens);

                _compEnterMarkets(2, _ctokens);

                _compDepositOne(data.collateralFee, _ctokens[1], token, depositAmt);
                _compBorrowOne(data.debtFee, _ctokens[0], dai, borrowAmt, Protocol.Aave, 2);
            } else {
                revert("invalid-option");
            }
        } else {
            if (data.toVaultId == 0) {
                _makerOpen(data.colType);
            }

            if (data.source == Protocol.Aave) {
                borrowAmt = _aaveV1PaybackOne(aaveV1, aaveCore, dai, data.debt);
                depositAmt = _aaveV1WithdrawOne(aaveV1, aaveCore, token, data.collateral);
            } else if (data.source == Protocol.AaveV2) {
                borrowAmt = _aaveV2PaybackOne(aaveV2, aaveData, dai, data.debt, data.paybackRateMode);
                depositAmt = _aaveV2WithdrawOne(aaveV2, aaveData, token, data.collateral);
            } else if (data.source == Protocol.Compound) {
                address _cDai = InstaMapping(getMappingAddr()).cTokenMapping(address(dai));
                address _cToken = InstaMapping(getMappingAddr()).cTokenMapping(data.token);

                CTokenInterface cDai = CTokenInterface(_cDai);
                CTokenInterface cToken = CTokenInterface(_cToken);

                borrowAmt = _compPaybackOne(cDai, dai, data.debt);
                depositAmt = _compWithdrawOne(cToken, token, data.collateral);
            } else {
                revert("invalid-option");
            }

            _makerDepositAndBorrow(data.toVaultId, depositAmt, borrowAmt, data.collateralFee, data.debtFee);
        }
    }
}

contract ConnectRefinance is RefinanceResolver {
    string public name = "Refinance-v1";
}
