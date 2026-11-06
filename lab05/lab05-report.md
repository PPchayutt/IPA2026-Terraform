<Question>
Question 1: Map each of the three settings above (versioning, encryption, public access block) to the state considerations in Chapter 6.2 — resiliency, security, availability. Which of the three considerations is not addressed by anything in this file, and what would address it?
Ans:  aws_s3_bucket_versioning ตรงกับ Resiliency เพื่อเก็บประวัติไฟล์ State ทุกเวอร์ชันไว้กู้คืนยามฉุกเฉิน aws_s3_bucket_server_side_encryption_configuration และ aws_s3_bucket_public_access_block ตรงกับ Security เพื่อเข้ารหัสข้อมูลและป้องกันไม่ให้ไฟล์ State รั่วไหลสู่สาธารณะ ส่วนข้อที่ไม่ได้ถูกจัดการด้วย Resource ในไฟล์นี้เลยคือ Availability ซึ่งได้รับการดูแลโดยโครงสร้างพื้นฐานของบริการ AWS S3 เอง ร่วมกับการเปิดใช้ State Locking ในบล็อก backend "s3" ของโปรเจกต์หลัก

Question 2: The bucket itself is not in Terraform state — only its configuration is. What does terraform destroy do to the bucket in this project, and what does that imply about who is responsible for deleting it?
Ans: คำสั่ง terraform destroy จะลบหรือรีเซ็ตเฉพาะการตั้งค่าทั้ง 3 รายการ ได้แก่ Versioning, Encryption และ Public Access Block เท่านั้น แต่ตัว S3 Bucket จะยังคงค้างอยู่ใน AWS ไม่ถูกลบไปด้วย หมายความว่าผู้ดูแลระบบต้องเป็นคนรับผิดชอบในการสั่งลบ Object ข้างในและลบตัว Bucket เองผ่าน AWS CLI หรือ AWS Console

Question 3: Compare the lineage value in S3 to the one you recorded in Lab 4. Is it the same? What does that tell you about what migration does?
Ans: ค่า lineage ของ Lab 5 ถูกสุ่มใหม่ตอนเริ่ม Step 2.1 ทำให้ไม่ตรงกับของ Lab 4 แต่จะตรงกับค่า lineage ในไฟล์ terraform.tfstate.backup ก่อนย้ายขึ้น S3 ใน Step 2.1 หรือหากย้ายจากไฟล์ State เดิมโดยตรง ค่า lineage ก็จะเป็นค่าเดิม ซึ่งสิ่งนี้บอกให้รู้ว่าการทำ State Migration เป็นการคัดลอกประวัติและเอกลักษณ์ของ State ชุดเดิมไปยังที่จัดเก็บใหม่ ไม่ใช่การเริ่มต้นสร้าง State ใหม่ตั้งแต่ศูนย์

Question 4: terraform force-unlock <LOCK_ID> exists. Describe a situation where you would need it, and the specific danger of using it when another apply really is still running.
Ans: ใช้เมื่อโปรเซสของ Terraform หรือเครื่องรัน CI/CD เกิดเน็ตหลุด ค้าง หรือดับกระทันหันระหว่างรันงาน ทำให้ Terraform ไม่มีโอกาสลบไฟล์ .tflock ออก และเกิดล็อกค้างจนไม่มีใครรันงานต่อได้ โดยหากมีอีก apply กำลังรันอยู่จริง จะทำให้เกิดการทำงานพร้อมกัน 2 โปรเซส ทั้งสองฝั่งจะสร้างหรือแก้ Resource บน AWS ชนกัน และต่างฝ่ายต่างเขียนทับไฟล์ terraform.tfstate ทับกัน จนทำให้ไฟล์ State พังเสียหาย หรือข้อมูลใน State ไม่ตรงกับของจริงบน Cloud

Question 5: Why is a moved block better than terraform state mv for a team? (Hint: what happens when your teammate pulls your branch?)
Ans: เพราะบล็อก moved ถูกเขียนไว้ในโค้ด .tf จึงถูกเก็บประวัติผ่าน Git ไปพร้อมกับโค้ด ในขณะที่ terraform state mv เป็นการรันคำสั่งแก้ไขเฉพาะไฟล์ State ก้อนเดียวแบบนอกรอบ หากมี Environment อื่นที่ใช้โค้ดเดียวกัน เพื่อนคนอื่นที่ดึง Branch ไปรันใน Environment อื่นก็จะเจอแผนสั่งลบและสร้าง Resource ใหม่ทั้งหมด

Question 6: Compare the import block to the older terraform import CLI command. Give two advantages of the block form.
Ans:  1) สามารถตรวจสอบล่วงหน้าในขั้นตอน terraform plan และทำ Code Review ได้ เพราะบล็อก import อยู่ในไฟล์โค้ด จึงสามารถรัน plan เพื่อดูผลกระทบก่อนรันจริง และส่งเข้า Git เพื่อให้ทีมช่วยตรวจสอบใน Pull Request รวมถึงรันผ่านระบบ CI/CD Pipeline ได้
	2) รองรับการสร้างโค้ดอัตโนมัติและนำเข้าพร้อมกันหลายรายการ เพราะสามารถใช้คู่กับแฟล็ก terraform plan -generate-config-out=generated.tf เพื่อให้ Terraform ช่วยเขียนบล็อก resource ให้โดยอัตโนมัติ และนำเข้า Resource จำนวนมากพร้อมกันในครั้งเดียวได้

Question 7: state rm leaves an orphaned resource in AWS. Describe one legitimate use case, and one way this could cost your organisation money.
Ans: กรณีการใช้งานที่เหมาะสม คือ เมื่อต้องการย้ายสิทธิ์การดูแล Resource นั้นไปยังโปรเจกต์ Terraform อื่น โดยถอดออกจาก State โปรเจกต์เดิมด้วย state rm แล้วนำไป import เข้าอีกโปรเจกต์หนึ่ง หรือต้องการเก็บข้อมูลสำคัญไว้บน Cloud เช่น Database/S3 ในขณะที่ต้องการสั่ง terraform destroy ลบส่วนอื่นๆ ของโปรเจกต์ทิ้ง ส่วนหากถอดออกจาก State แล้วลืมไปตามลบด้วยมือและไม่ได้นำเข้าโปรเจกต์อื่น Resource นั้นจะกลายเป็น Orphaned resource ที่รันทิ้งไว้บน AWS ตลอดเวลาโดยไม่มีโค้ด Terraform ตัวไหนคอยติดตามดูแล และไม่ถูกลบเมื่อสั่ง terraform destroy ทำให้องค์กรต้องเสียค่าใช้จ่ายรายเดือนไปเรื่อยๆ โดยไม่รู้ตัว

Question 8: The two files have different serial values and may have different lineage. If you ran terraform state push terraform.tfstate.lab4-backup right now, what would Terraform do, and why is that protection valuable? (Do not actually run it.)
Ans: Terraform จะปฏิเสธการอัปโหลดและแจ้ง Error ทันที โดยการป้องกันนี้มีคุณค่ามากเพราะช่วยป้องกันความผิดพลาดของมนุษย์ไม่ให้เผลอนำไฟล์ State ของคนละโปรเจกต์ หรือไฟล์ State เวอร์ชันเก่าที่ล้าสมัยแล้วไปเขียนทับข้อมูล State ล่าสุดของทีมจนพัง


<Checkpoint>
Checkpoint 1: Record your bucket name and show terraform state list for the bootstrap project.
	- Bucket ชื่อ ipa-tfstate-d4cd6c89
	- ผลลัพธ์จาก terraform state list คือ aws_s3_bucket_public_access_block.state, aws_s3_bucket_server_side_encryption_configuration.state และ aws_s3_bucket_versioning.state

Checkpoint 2: Show that terraform state list still returns all your resources even though the local state file is gone.
	pitch@Pitchayut-PC UCRT64 ~/OneDrive/เอกสาร/GitHub/ipa26/lab05 (main)
	$ cat terraform.tfstate

	pitch@Pitchayut-PC UCRT64 ~/OneDrive/เอกสาร/GitHub/ipa26/lab05 (main)
	$ ls -l terraform.tfstate.backup
	-rw-r--r-- 1 pitch 197609 42071 Nov  6 22:08 terraform.tfstate.backup

	pitch@Pitchayut-PC UCRT64 ~/OneDrive/เอกสาร/GitHub/ipa26/lab05 (main)
	$ aws s3 ls "s3://$BUCKET/lab05/"
	2026-11-06 22:08:48      42070 terraform.tfstate

	pitch@Pitchayut-PC UCRT64 ~/OneDrive/เอกสาร/GitHub/ipa26/lab05 (main)
	$ aws s3 cp "s3://$BUCKET/lab05/terraform.tfstate" - | jq '{serial, lineage}'
	{
  	"serial": 1,
  	"lineage": "13b81d77-57ff-83cf-db42-f808434ac91b"
	}

	pitch@Pitchayut-PC UCRT64 ~/OneDrive/เอกสาร/GitHub/ipa26/lab05 (main)
	$ terraform state list
	module.vpc.aws_default_network_acl.this[0]
	module.vpc.aws_default_route_table.default[0]
	module.vpc.aws_default_security_group.this[0]
	module.vpc.aws_internet_gateway.this[0]
	module.vpc.aws_route.public_internet_gateway[0]
	module.vpc.aws_route_table.public[0]
	module.vpc.aws_route_table_association.public[0]
	module.vpc.aws_route_table_association.public[1]
	module.vpc.aws_subnet.public[0]
	module.vpc.aws_subnet.public[1]
	module.vpc.aws_vpc.this[0]
	module.web_server.data.aws_ami.amazon_linux
	module.web_server.aws_instance.server["api"]
	module.web_server.aws_instance.server["web"]
	module.web_server.aws_security_group.web

Checkpoint 3: Capture the error from Terminal 2. Record the Lock ID, Who, Created, and Operation fields.
	- ID: 557d5358-6440-a8da-4ee0-244cef2c2af1
	- Operation:  OperationTypeApply
	- Who: PITCHAYUT-PC\pitch@Pitchayut-PC
	- Created:  2026-11-06 15:24:16.6821153 +0000 UTC

Checkpoint 4: Show the before and after plans.
	- terraform plan ครั้งแรกขึ้นว่าจะ Destroy module.web_server.* และ Create module.web.*
	- หลังรัน terraform state mv module.web_server module.web ไปแล้ว พอรัน terraform plan ต่อจะขึ้นว่า No changes.
	
Checkpoint 5: Show terraform state show aws_dynamodb_table.adopted proving the table is now managed.
	pitch@Pitchayut-PC UCRT64 ~/OneDrive/เอกสาร/GitHub/ipa26/lab05 (main)
	$ terraform state show aws_dynamodb_table.adopted
	# aws_dynamodb_table.adopted:
	resource "aws_dynamodb_table" "adopted" {
    		arn                         = "arn:aws:dynamodb:us-east-1:983631791995:table/ipa-adopted-12582"
    		billing_mode                = "PAY_PER_REQUEST"
    		deletion_protection_enabled = false
    		hash_key                    = "id"
   		id                          = "ipa-adopted-12582"
    		name                        = "ipa-adopted-12582"
    		read_capacity               = 0
   		region                      = "us-east-1"
    		stream_arn                  = null
    		stream_enabled              = false
    		stream_label                = null
    		stream_view_type            = null
    		table_class                 = "STANDARD"
    		tags                        = {}
    		tags_all                    = {
        		"Course"    = "IPA-Terraform"
        		"ManagedBy" = "Terraform"
   		}
    		write_capacity              = 0

   		attribute {
       			name = "id"
        		type = "S"
    		}

    		point_in_time_recovery {
        		enabled                 = false
        		recovery_period_in_days = 0
    		}

    		ttl {
        		attribute_name = null
        		enabled        = false
    		}
	}


Lab Report & Checkpoints Pictures (Google Docs): https://docs.google.com/document/d/1mCGgyQmoUGoMq13fedEhnpDl1yXTsZKcCSowlbGjZsU/edit?tab=t.jhy0oiaibdag