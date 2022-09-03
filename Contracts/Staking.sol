// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

error Staking__TransferFailed();//custom error:contract name two under and wat error is 
error Staking__NeedsMoreThanZero();	
	
contract Staking {
	//how much each address has been paid
	mapping(address=> uint256) public s_userRewardperTokenPaid;
	//someoneadress=>howmuchtheystake
	mapping(address => uint256) public s_balance;
	// how much rewawrd each address has to claim
	mapping(address =>uint256) public s_rewards;
	uint256 public constant REWARD_RATE=100;
	uint256 public s_totalSupply;
	uint256 public s_rewardPerTokenStored;
	uint256 public s_lastUpdateTime;
	IERC20 address public s_stakingToken;
	IERC20 address public s_rewardToken;
	modifier updateReward(address account){
		//how much reward per token?
		//last timestamp
		//12-1,user earn X token
		s_rewardPerTokenStored = rewardPerToken();
		s_lastUpdateTime=block.timestamp;
		s_reward[account]=earned(account);
		s_userRewardperTokenPaid[account]=s_rewardPerTokenStored;
		_;
	}
			modifier moreThanZero(uint256 amount){
				if(amount ==0){
					revert Staking__NeedsMoreThanZero();
				}
				_;
			}

	constructor(address stakingToken,address rewardToken){

		s_stakingToken =IERC20(stakingToken);
		s_rewardToken =IERC20(rewardToken);

}

		function earned(address account)public view returns (uint256){
			uint256 currentBalance=s_balances[account];
			//how much they have beein paid already
			uint256 amountPaid= s_userRewardperTokenPaid[account];
			uint256 currentRewardPerToken=rewardPerToken();
			uint256 pastRewards=s_rewards[account];
			uint256 _earned= (currentBalance*(currentRewardPerToken-amountPaid))/1e18) +
				pastRewards;
			return _earned;
		}
	//based on how long its been during this most recent snapshot
	function rewardPerToken public view returns (uint256){
		if(s_totalSupply==0)

			return s_rewardPerTokenStored;
		}
		return s_rewardPerTokenStored + (((block.timestamp-s_lastUpdateTime)*REWARD_RATE* 1e18)/s_totalSupply);
	}
			//just a specific token can be staked

	function stake(uint256 amount) external updateReward(msg.sender) MoreThanZero(amount) {
		//how much this user has staked
		//keep track of how much token we have total
		//transfer tokens to this contract
		s_balances[msg.sender]=s_balances[msg.sender]+amount;
		s_totalSupply =s_totalSupply+amount;
		//emit event
		bool success= s_stakingToken.transferFrom(msg.sender,address(this),amount);
		//require(success,"Failed");
		if(!success){
			revert Staking__TransferFailed();
		}
}
	function withdraw(uint256 amount)external updateReward(msg.sender) MoreThanZero(amount) {
		s_balances[msg.sender]=s_balances[ms.sender]-amount;
		s_totalSupply=s_totalSupply-amount;
		bool success=s_stakingToken.transfer(msg.sender,amount);//weusetransfercuz now ourstaking contract has acces to tokens,last one was from user so we used transferfrom
		//same as: bool succes=s_stakingToken.transfer(address(this),msg.sender,amount);
		if(!succes){
			revert Staking__TransferFailed;
		}
	}
		function claimReward() external updateReward(msg.sender)  {

			uint256 reward = s_rewards [msg.sender];

			bool succes= s_rewardsToken.transfer(msg.sender,reward);
			if(!succes){
				revert Staking__TransferFailed();
			}
			//how much reward do they get?

			//mechanism: emit X Token per second
			//disperse them to all token stakers
			//100 token /second
			// staked:50 staked tokens,20 staked,30 staked 
			//rewards :50 reward,20,30 

			//staked: 100,50,20,30(total=200)
			//rewards: 50,25,10,15
			// why not 1 to1? its fcked up
			// 5 seconds, 1 person 100 token staked=reward 500 token
			//6 second,2 person have 100 token staked each:
			//person 1 :550 (he/she was there 5 seconds ago)
			//person 2 :50
			//betwen 1-5 second person 1 got 500 and at second 6 ,person 1 get 50 token


		}

}