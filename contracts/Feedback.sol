pragma solidity ^0.6.0;

//Smart contract for Decentralized Feedback System
contract MyContract{


    //to check whether the Person has voted or not
    enum State {NONE,VOTED}

    //to check whether the Contract is active or not
    enum contractState {ACTIVE,INACTIVE}

    //initially set to inactive
    contractState state = contractState.INACTIVE;

    address private commisioner;

    event votedEvent (
        address indexed _policyAddress
    );

    event added(string _message, address indexed _address);

    //defining structure of the Policymaker
    struct Policymaker
    {

        string name;
        uint id;
        uint constituency;
        bool exists;
    }

    //defining Structure of the Policy
    struct Policy
    {
        bytes32 details; //stores only the hash of the actual statement
        bytes32 beneficiary; //stores only the hash of the actual beneficiary criteria
        address framer;
        uint creditPoints;
        uint voteCountFor;
        uint votecountAgainst;
        bool exists;

    }

    //defining the structure of the feedback
    struct Feedback
    {
        address policy;
        State feedback;
    }

    //defining the structure of the person
    struct Person
    {
        uint id;
        string name;
        //initializing a dynamic array for the feedbacks
        //stores the feedback everytime the person votes in for a policy with the profile
        uint credits;
        uint numPolcies; //counts the number of policies the person is enrolled in
        Feedback[] feedbacks;
        bool exists;
    }

    //mapping of the address to the policymaker
    mapping (address => Policymaker) public policymakers;

    //mapping of the address to the person
    mapping (address => Policy) public policies;

    //mapping of the address to the policy
    mapping(address => Person) public persons;

    //setting the state to active
    constructor() public
    {
        commisioner = msg.sender;
        state = contractState.ACTIVE;

    }

    //setting up the permissions an passing thee _personAddress as a key
    //initializing the parameters of the function
    //mapping of the address to the Person
    function addPerson(uint _id, string memory _name, address _personAddress) public
    {
        require(msg.sender == commisioner, "Only Commisioner can take this action!");
        require(!persons[_personAddress].exists,"Person already exists!");

        persons[_personAddress].id = _id;
        persons[_personAddress].name = _name;
        persons[_personAddress].numPolcies = 0;
        persons[_personAddress].credits = 0;
        persons[_personAddress].exists = true;

        emit added("Added Person into the system", _personAddress);

    }

        //setting up the permissions an passing thee _personAddress as a key
        //initializing the parameters of the function
        //mapping of the address to the Policymaker

    function addPolicymaker(address _policymakerAddress,string memory _name, uint _id,uint _constituency) public
    {
        require(msg.sender == commisioner, "Only the commisioner can take this action!");
        require(!policymakers[_policymakerAddress].exists, "Policymaker already exists in the system!");

        policymakers[_policymakerAddress].name = _name;
        policymakers[_policymakerAddress].id = _id;
        policymakers[_policymakerAddress].constituency = _constituency;
        policymakers[_policymakerAddress].exists = true;

        emit added("Added PolicyMaker to the system", _policymakerAddress);
    }

        //setting up the permissions an passing thee _personAddress as a key
        //initializing the parameters of the function
        //mapping of the address to the Policy

    function addPolicy( address _policyAddress,address _framer, bytes32 _beneficiary, bytes32 _details, uint _credits) public
    {
        require(msg.sender == commisioner, "Only the commisioner can take this action!");
        require(policymakers[_framer].exists, "Policy maker must exist in the system!");
        require(!policies[_policyAddress].exists, "Policy already exists at this address!");


        policies[_policyAddress].details = _details;
        policies[_policyAddress].beneficiary = _beneficiary;
        policies[_policyAddress].framer = _framer;
        policies[_policyAddress].creditPoints = _credits;
        policies[_policyAddress].exists = true;

        emit added("Added Policy to the System", _policyAddress);
    }

    //enrolls person into a Policy
    function enrollPerson(address _policyAddress,address _personAddress) public
     {
        require(msg.sender == commisioner, "Only Commisioner can do this!");
        require(policies[_policyAddress].exists,"Policy must exist!");
        require(persons[_personAddress].exists, "Person must exist!");

        persons[_personAddress].numPolcies++;
        persons[_personAddress].feedbacks.push(Feedback(_policyAddress, State.NONE));
    }

    function vote(address _policyAddress) public
    {
      //require person has not voted before
      require(persons[msg.sender].exists, "Only the beneficiary can vote for the Feedback!");
      require(policies[_policyAddress].exists, "Policy must exist in the system!");

      uint i;
      for(i = 0;i<persons[msg.sender].numPolcies;i++){

          //check if the person is enrolled in the policy and has not yet voted.
          if(persons[msg.sender].feedbacks[i].policy == _policyAddress && persons[msg.sender].feedbacks[i].feedback == State.NONE)
          {
            persons[msg.sender].feedbacks[i].feedback = State.VOTED;
            persons[msg.sender].credits += policies[_policyAddress].creditPoints;
          }
          else
          revert("The Beneficiary is not enrolled in the Policy.");
      }

      // trigger voted event
        emit votedEvent(_policyAddress);
    }

    function withdraw(uint withdrawAmount) public returns (uint) 

    {
      /* If the sender's balance is at least the amount they want to withdraw,
         Subtract the amount from the sender's balance, and try to send that amount of ether
         to the user attempting to withdraw. IF the send fails, add the amount back to the user's balance
         return the user's balance.*/
      address user = msg.sender;

      // require(withdrawAmount >= owner.balance);
      require(persons[user].credits >= withdrawAmount);

      persons[user].credits -= withdrawAmount;

      user.transfer(withdrawAmount);

      return persons[user].credits;
  }




  function balance() public view returns (uint)

   {
      /* Get the balance of the sender of this transaction */
      address user = msg.sender;

      return persons[user].credits;
  }



}
