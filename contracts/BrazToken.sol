// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract BrazToken {
    // Estruturas básicas
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    
    // Mapeamentos
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;
    mapping(address => bool) public isBlackListed;
    
    // Controles administrativos
    address public owner;
    bool public paused;
    
    // Eventos
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Pause();
    event Unpause();
    event Issue(uint amount);
    event Redeem(uint amount);
    event AddedBlackList(address user);
    event RemovedBlackList(address user);
    event DestroyedBlackFunds(address blackListedUser, uint balance);

    // Modificadores
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }
    
    modifier whenPaused() {
        require(paused, "Not paused");
        _;
    }
    
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4, "Payload too small");
        _;
    }

    constructor(
        uint _initialSupply,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply;
        owner = msg.sender;
        balances[owner] = _initialSupply;
        emit Transfer(address(0), owner, _initialSupply);
    }

    // Funções ERC20
    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }
    
    function transfer(address to, uint value) public whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender], "Sender blacklisted");
        
        balances[msg.sender] -= value;
        balances[to] += value;
        
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public whenNotPaused returns (bool) {
        require(!isBlackListed[from], "From address blacklisted");
        
        uint currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= value, "Allowance exceeded");
        
        if (currentAllowance != type(uint).max) {
            allowances[from][msg.sender] = currentAllowance - value;
        }
        
        balances[from] -= value;
        balances[to] += value;
        
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public whenNotPaused onlyPayloadSize(2 * 32) returns (bool) {
        require(value == 0 || allowances[msg.sender][spender] == 0, "Reset allowance first");
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address _owner, address spender) public view returns (uint) {
        return allowances[_owner][spender];
    }

    // Funções administrativas
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }
    
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
    
    function issue(uint amount) public onlyOwner {
        balances[owner] += amount;
        totalSupply += amount;
        emit Issue(amount);
        emit Transfer(address(0), owner, amount);
    }
    
    function redeem(uint amount) public onlyOwner {
        require(balances[owner] >= amount, "Insufficient balance");
        balances[owner] -= amount;
        totalSupply -= amount;
        emit Redeem(amount);
        emit Transfer(owner, address(0), amount);
    }
    
    function addBlackList(address user) public onlyOwner {
        isBlackListed[user] = true;
        emit AddedBlackList(user);
    }
    
    function removeBlackList(address user) public onlyOwner {
        isBlackListed[user] = false;
        emit RemovedBlackList(user);
    }
    
    function destroyBlackFunds(address blackListedUser) public onlyOwner {
        require(isBlackListed[blackListedUser], "Not blacklisted");
        uint dirtyFunds = balances[blackListedUser];
        balances[blackListedUser] = 0;
        totalSupply -= dirtyFunds;
        emit DestroyedBlackFunds(blackListedUser, dirtyFunds);
        emit Transfer(blackListedUser, address(0), dirtyFunds);
    }
}
