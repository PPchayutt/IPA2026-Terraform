<Question>
Question 1: Map each of the three settings above (versioning, encryption, public access block) to the state considerations in Chapter 6.2 — resiliency, security, availability. Which of the three considerations is not addressed by anything in this file, and what would address it?
Ans: 

Question 2: The bucket itself is not in Terraform state — only its configuration is. What does terraform destroy do to the bucket in this project, and what does that imply about who is responsible for deleting it?
Ans: 

Question 3: Compare the lineage value in S3 to the one you recorded in Lab 4. Is it the same? What does that tell you about what migration does?
Ans: 

Question 4: terraform force-unlock <LOCK_ID> exists. Describe a situation where you would need it, and the specific danger of using it when another apply really is still running.
Ans: 

Question 5: Why is a moved block better than terraform state mv for a team? (Hint: what happens when your teammate pulls your branch?)
Ans: 

Question 6: Compare the import block to the older terraform import CLI command. Give two advantages of the block form.
Ans: 

Question 7: state rm leaves an orphaned resource in AWS. Describe one legitimate use case, and one way this could cost your organisation money.
Ans: 

Question 8: The two files have different serial values and may have different lineage. If you ran terraform state push terraform.tfstate.lab4-backup right now, what would Terraform do, and why is that protection valuable? (Do not actually run it.)
Ans: 


<Checkpoint>
Checkpoint 1: Record your bucket name and show terraform state list for the bootstrap project.
	- 

Checkpoint 2: Show that terraform state list still returns all your resources even though the local state file is gone.
	- 

Checkpoint 3: Capture the error from Terminal 2. Record the Lock ID, Who, Created, and Operation fields.
	- 

Checkpoint 4: Show the before and after plans.
	- 
	
Checkpoint 5: Show terraform state show aws_dynamodb_table.adopted proving the table is now managed.
	-  


Lab Report & Checkpoints Pictures (Google Docs): https://docs.google.com/document/d/1mCGgyQmoUGoMq13fedEhnpDl1yXTsZKcCSowlbGjZsU/edit?tab=t.y2ksqctukw77