<Question>
Question 1: Which nodes have no incoming dependencies — what can Terraform start on immediately? You should find more than one. Why does the AMI data source appear among them?
Ans: 

Question 2: Trace the path from module.web_server.data.aws_ami.amazon_linux to module.web_server.aws_instance.server["web"]. List every node on the path.
Ans: 

Question 3: Name two resources that have no dependency relationship. Terraform can create these in parallel — why does that matter for apply speed?
Ans: 

Question 4: module.web_server.aws_security_group.web depends on module.vpc. Nothing in modules/web-server/main.tf mentions the VPC module by name. Where does that edge come from?
Ans: 

Question 5: Why does Terraform behave this way? What would go wrong if it applied the stale plan anyway?
Ans: 

Question 6: Destroy order is the reverse of create order. Using your graph from Part 1, explain why the security group cannot be destroyed before the instances, and why the VPC cannot be destroyed before the security group.
Ans: 

Question 7: The Terraform documentation calls -target an option for “exceptional situations” only. Give two reasons why routine use of -target is dangerous.
Ans: 

Question 8: -refresh=false is faster. What is the trade-off?
Ans: 

Question 9: The book warns against passing secrets as -var on the command line. Give two reasons why.
Ans: 

Question 10: What is serial used for? What is lineage used for? Why would Terraform refuse to write state whose lineage does not match?
Ans: 

Question 11: aws_instance.server appears once in state with two instances, not twice. What does the index_key field on each instance hold, and how does that differ from what you would have seen if Lab 3 had kept count?
Ans: 

Question 12: Given what you just saw, list three requirements a production state backend must satisfy (see Chapter 6.2: resiliency, security, availability).
Ans: 

Question 13: What happens if a colleague with an older Terraform tries to run apply against state written by your newer version? Why is this restriction one-directional?
Ans: 


<Checkpoint>
Checkpoint 1: Include both graph.svg and graph-plan.svg in your report and describe one difference.
	- 

Checkpoint 2: What happened? Did Terraform apply the stale plan or refuse?
	- 

Checkpoint 3: Show both outputs. Explain the difference between what -refresh-only reports and what a normal plan proposes to do about the drift.
	- 

Checkpoint 4: Confirm the instance ID changed. Run terraform output before and after — server_summary and all_private_ips both come from Lab 3’s instances output, so both should move.
	- 
	
Checkpoint 5: Complete this table in your report, ordering from lowest to highest priority:
	-  

Checkpoint 6: Record the version, terraform_version, serial and lineage values, and the resource count. Compare that count with the number of resource blocks you actually wrote.
	- 

Checkpoint 7: Locate your admin_password output in the state file. It is declared sensitive = true, so Terraform hides it in CLI output. Is it encrypted in the state file? Is it obfuscated in any way?
	- 

Checkpoint 8: For each pitfall you chose, submit: the error output, a one-paragraph diagnosis, and the corrected configuration.
	- 

Lab Report & Checkpoints Pictures (Google Docs): https://docs.google.com/document/d/1mCGgyQmoUGoMq13fedEhnpDl1yXTsZKcCSowlbGjZsU/edit?tab=t.y2ksqctukw77