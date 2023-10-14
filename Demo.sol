// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ;

contract Registration
{  
    uint256 cur=1 ;
    mapping(address => uint256) public registered_users ; //To store the addresses of already registered users.
    /*To make sure the registered users are legit, sales team could contact Superconnectors
    and Corporates within one to two days of their registry date, and confirm their identity.*/
    
    uint256 public total_registered_users ;
    
    uint256[] ignored_registrations ;
    /*Since we can't alter or delete registration data after they are already on the blockchain, 
    this is a dynamic array that keeps track of the users we want to drop of our users table,
    due to unsubscribing, fake accounts, etc...*/

    address public owner ;
    /*This is where we store the address of the owner of this contract (MONET)*/

    struct UserData
    {
        string kind ; //Influencer or Corporate
        string full_name ;
        string email ;
        string country ;
        string mobile_number ;
        address wallet_address ; //User's wallet address
        uint registration_time ; //Timestamp of the registration
    }
    /*Parameters can be modified according to MONET's management*/

    UserData[] users ; //The array that we store users details at.
    
    constructor()
    {
        owner = msg.sender ; // Set the contract creator as the owner
        total_registered_users=0 ;
    }

    //The Registration Function:
    function register(
        string memory _kind,
        string memory _full_name,
        string memory _email,
        string memory _country,
        string memory _mobile_number,
        address _wallet_address) public
    {
        require(registered_users[msg.sender]!=0, "Already registered") ;

        UserData memory data = UserData({
            kind: _kind,
            full_name: _full_name,
            email: _email,
            country: _country,
            mobile_number: _mobile_number,
            wallet_address: _wallet_address,
            registration_time: block.timestamp
        }) ;

        users.push(data) ;//Adding the user to our users array.

        registered_users[msg.sender] = cur ;//Adding the address of the user to the registered users.
        cur++ ;
        total_registered_users++ ;
    }

    //Displaying users information
    function getAllUsers() public view returns (UserData[] memory) 
    {
        require(registered_users[msg.sender]!=0 || msg.sender == owner, "This data is accessable only by registered users.") ;
        return users ;
    }

    //A function that displays the indecies of the ignored accounts,
    // so they can be excluded from any database or tables.
    function getIgnoredUsers() public view returns (uint256[] memory) 
    {
        require(registered_users[msg.sender]!=0 || msg.sender == owner, "This data is accessable only by registered users.") ;
        return ignored_registrations ;
    }

    //This function can be used only by the owner of the contract. It is used to delete
    // a user (mark it ignored, and empty its mapped address value). We can't delete data after being
    // added into blocks, so this is an efficient way to identify ignored accounts.
    function deleteUser(address _address) public
    {
        require(msg.sender == owner, "Only the owner can call this function") ;
        require(registered_users[_address]!=0) ;
        
        ignored_registrations.push(registered_users[_address]-1) ;
        registered_users[_address]=0 ;
        total_registered_users-- ;
    } 
}  
