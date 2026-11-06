<Question>
Question 1: Which nodes have no incoming dependencies — what can Terraform start on immediately? You should find more than one. Why does the AMI data source appear among them?
Ans: สังเกตจากผลลัพธ์จะเห็นว่า module.web_server.data.aws_ami.amazon_linux และ module.vpc.aws_vpc.this ไม่มีลูกศรชี้ต่อไปหา Resource อื่นเลย ซึ่งจะแปลว่าทั้งสองตัวนี้ไม่มี Dependency ที่ต้องรอและ Terraform เริ่มทำได้ทันทีตั้งแต่ต้น โดยสาเหตุที่ AMI data source เริ่มได้ทันทีเพราะเป็นการอ่านค่า AMI ที่มีอยู่แล้วบน AWS เพียงอย่างเดียว ไม่ได้พึ่งพา Resource ใดๆ ที่เรากำลังจะสร้าง

Question 2: Trace the path from module.web_server.data.aws_ami.amazon_linux to module.web_server.aws_instance.server["web"]. List every node on the path.
Ans: เส้นทางเชื่อมถึงกันโดยตรงเพียง 2 โหนด คือจาก module.web_server.data.aws_ami.amazon_linux ไปยัง module.web_server.aws_instance.server ซึ่งครอบคลุมเครื่อง ["web"] โดยไม่มีโหนดอื่นคั่นกลาง

Question 3: Name two resources that have no dependency relationship. Terraform can create these in parallel — why does that matter for apply speed?
Ans: module.vpc.aws_subnet.public กับ module.web_server.aws_security_group.web ไม่มีเส้นลูกศรเชื่อมหากันเลย รวมถึงเครื่อง server["web"] กับ server["api"] ก็ไม่ได้พึ่งพากัน การไม่มี Dependency ต่อกันทำให้ Terraform สั่งสร้างพร้อมกันแบบขนานได้ ช่วยลดเวลารอคิว API และทำให้ terraform apply เสร็จเร็วขึ้นมาก

Question 4: module.web_server.aws_security_group.web depends on module.vpc. Nothing in modules/web-server/main.tf mentions the VPC module by name. Where does that edge come from?
Ans: เส้นนี้เกิดจากการส่งค่าตัวแปรข้ามโมดูลที่ไฟล์ main.tf ของ Root ซึ่งรับค่า vpc_id = module.vpc.vpc_id ส่งเข้าไปในตัวแปร var.vpc_id ของ module.web_server

Question 5: Why does Terraform behave this way? What would go wrong if it applied the stale plan anyway?
Ans: เพราะไฟล์ Plan มีไว้เพื่อรับประกันว่าสิ่งที่ถูกนำไป apply จริงจะต้องตรงกับสิ่งที่ได้รับการตรวจสอบไว้ หากยอมให้รันไฟล์ Plan ที่ล้าสมัยได้ การแก้ไขโค้ดใหม่หรือสถานะที่เปลี่ยนไปในระหว่างนั้นจะถูกเพิกเฉยหรือถูกเขียนทับ ทำให้ได้ Infrastructure ที่ไม่ตรงกับโค้ดปัจจุบันและอาจทำให้ระบบพังได้

Question 6: Destroy order is the reverse of create order. Using your graph from Part 1, explain why the security group cannot be destroyed before the instances, and why the VPC cannot be destroyed before the security group.
Ans: เพราะตามลำดับ Dependency ในกราฟ aws_instance.server ต้องพึ่งพา aws_security_group.web และบน AWS เราไม่สามารถลบ Security Group ที่ยังมี EC2 Instance ผูกใช้งานอยู่ได้ จึงต้องลบ Instances ก่อน เสร็จแล้วตัว aws_security_group.web ก็ถูกสร้างอยู่ภายใน module.vpc ซึ่ง AWS ไม่ยอมให้ลบ VPC จนกว่า Resource ย่อยข้างในอย่าง Security Group และ Subnet จะถูกลบออกจนหมด

Question 7: The Terraform documentation calls -target an option for “exceptional situations” only. Give two reasons why routine use of -target is dangerous.
Ans: อาจจะพลาดความสัมพันธ์ที่ซ่อนอยู่ เพราะว่าการอัปเดตเฉพาะจุดอาจทำให้ Resource อื่นที่ต้องรับค่าต่อเนื่องกันไม่ได้ถูกอัปเดตตาม จนระบบทำงานผิดพลาด และเกิดความไม่สอดคล้องกันระหว่างโค้ดกับระบบจริง

Question 8: -refresh=false is faster. What is the trade-off?
Ans: Terraform จะไม่ออกไปเรียก API ตรวจสอบสถานะจริงบน Cloud เลย แต่จะเชื่อข้อมูลเก่าที่แคชไว้ในไฟล์ terraform.tfstate เท่านั้น ทำให้ตรวจไม่พบการเปลี่ยนแปลงที่เกิดขึ้นนอกรอบ และอาจวางแผน Apply ผิดพลาดหากมีคนไปแก้ไขหรือลบ Resource บน AWS Console

Question 9: The book warns against passing secrets as -var on the command line. Give two reasons why.
Ans:  1) คำสั่งและรหัสผ่านที่พิมพ์จะถูกบันทึกเป็นข้อความธรรมดาไว้ในไฟล์ประวัติการใช้คำสั่งของ Shell เช่น ~/.bash_history หรือ PowerShell history ทำให้ถูกเปิดดูย้อนหลังได้
	2) ขณะที่ Terraform กำลังทำงาน ผู้ใช้อื่นบนระบบเดียวกันสามารถดูอาร์กิวเมนต์ของคำสั่งผ่านตาราง Process ของ OS เช่น ps aux หรืออาจหลุดไปแสดงผลในหน้า Log ของระบบ CI/CD ได้

Question 10: What is serial used for? What is lineage used for? Why would Terraform refuse to write state whose lineage does not match?
Ans: serial เป็นตัวเลขที่เพิ่มขึ้นเรื่อยๆ ทุกครั้งที่มีการเปลี่ยนแปลง State ใช้สำหรับตรวจจับการชนกันของข้อมูล เพื่อป้องกันไม่ให้ไฟล์ State เวอร์ชันเก่าถูกนำมาเขียนทับเวอร์ชันที่ใหม่กว่า ส่วน lineage เป็นรหัส UUID เฉพาะตัวที่ถูกสร้างขึ้นตอนเริ่มต้นโปรเจกต์ ใช้ระบุว่าเป็นไฟล์ State ของ Infrastructure ชุดเดียวกัน โดยจะปฏิเสธเมื่อ lineage ไม่ตรง เพื่อป้องกันความเสียหายร้ายแรงจากการเผลอนำไฟล์ State ของโปรเจกต์อื่นหรือสภาพแวดล้อมอื่นมาเขียนทับข้ามโปรเจกต์
	 
Question 11: aws_instance.server appears once in state with two instances, not twice. What does the index_key field on each instance hold, and how does that differ from what you would have seen if Lab 3 had kept count?
Ans: ฟิลด์ index_key เก็บค่าเป็น String ของคีย์ใน Map คือ "api" และ "web" เพราะใช้ for_each แต่ถ้าใช้ count ฟิลด์ index_key จะเก็บค่าเป็น ตัวเลขจำนวนเต็ม คือ 0 และ 1 แทน

Question 12: Given what you just saw, list three requirements a production state backend must satisfy (see Chapter 6.2: resiliency, security, availability).
Ans:  1) Resiliency ต้องจัดเก็บในระบบที่มีความทนทานสูง มีการสำรองข้อมูลและเปิดใช้งาน Versioning เพื่อกู้คืนได้หากไฟล์สูญหายหรือพัง
	2) Security ต้องมีการเข้ารหัสข้อมูลทั้งตอนจัดเก็บและส่งผ่านเครือข่าย และจำกัดสิทธิ์การเข้าถึงอย่างเข้มงวด เพราะข้างในมีรหัสผ่านเก็บเป็น Plaintext
	3) Availability ต้องให้สมาชิกในทีมเข้าถึงไฟล์ State ร่วมกันได้จากศูนย์กลาง และมีระบบ State Locking ป้องกันไม่ให้คนสองคนรัน apply ทับกันพร้อมกัน

Question 13: What happens if a colleague with an older Terraform tries to run apply against state written by your newer version? Why is this restriction one-directional?
Ans: Terraform เวอร์ชันเก่ากว่าจะปฏิเสธการทำงานและแจ้ง Error ทันที  เพราะ Terraform เวอร์ชันใหม่ถูกออกแบบให้รู้จักโครงสร้างของเวอร์ชันเก่าและอัปเกรดขึ้นได้ แต่เวอร์ชันเก่าไม่รู้จักฟีเจอร์หรือโครงสร้าง Schema ที่ออกใหม่ในอนาคต หากฝืนให้เวอร์ชันเก่าเขียนทับจะทำให้ข้อมูลใน State เสียหายได้


<Checkpoint>
Checkpoint 1: Include both graph.svg and graph-plan.svg in your report and describe one difference.
	- ใน graph.svg ที่เป็นกราฟจากโค้ด Configuration เครื่อง EC2 จะแสดงเป็นโหนดรวมเพียงก้อนเดียวคือ module.web_server.aws_instance.server
	- ใน graph-plan.svg ที่เป็นกราฟจากการทำงานจริงใน Plan ตัว Terraform จะกระจาย for_each ออกเป็นโหนดแยกตามคีย์จริงถึง 2 โหนด คือ module.web_server.aws_instance.server["api"] และ module.web_server.aws_instance.server["web"]

Checkpoint 2: What happened? Did Terraform apply the stale plan or refuse?
	- Terraform ปฏิเสธการรัน (Refuse) และแจ้ง Error ว่าไฟล์ Plan ที่บันทึกไว้ไม่ตรงกับโค้ดหรือสถานะปัจจุบันแล้ว (Saved plan is stale)

Checkpoint 3: Show both outputs. Explain the difference between what -refresh-only reports and what a normal plan proposes to do about the drift.
	- terraform plan -refresh-only จะตรวจพบว่ามีแท็ก ManualChange = "true" เพิ่มขึ้นมาบน AWS จริง และเสนอให้อัปเดตเฉพาะไฟล์ terraform.tfstate ให้ตรงกับความจริง โดยไม่ไปลบหรือแก้ไขอะไรบน AWS
	- terraform plan จะยึดโค้ด .tf เป็นศูนย์กลาง จึงมองว่าแท็ก ManualChange = "true" เกินมาจากโค้ด และเสนอให้ทำการแก้ไข Resource บน AWS โดยการลบแท็ก ManualChange ทิ้ง เพื่อให้ระบบจริงกลับมาตรงกับโค้ด

Checkpoint 4: Confirm the instance ID changed. Run terraform output before and after — server_summary and all_private_ips both come from Lab 3’s instances output, so both should move.
	- จะเห็นว่าใน server_summary และ all_private_ips ค่า Instance ID และ Private IP ของเครื่อง "web" เปลี่ยนเป็นค่าใหม่ ในขณะที่เครื่อง "api" ยังคงเป็น ID และ IP เดิม
	
Checkpoint 5: Complete this table in your report, ordering from lowest to highest priority:
	Rank			Source										Value observed
	- 1 (lowest)	default in variables.tf								"from-default"
	- 2			Environment variable (TF_VAR_precedence_demo)		"from-env-var"
	- 3			terraform.tfvars (auto-loaded)						"from-tfvars-file"
	- 4			Explicit var file (-var-file=custom.tfvars)					Explicit var file (-var-file=custom.tfvars)
	- 5 (highest)	Command line flag (-var="precedence_demo=from-cli")		"from-cli"

Checkpoint 6: Record the version, terraform_version, serial and lineage values, and the resource count. Compare that count with the number of resource blocks you actually wrote.
	- "version": 4, "terraform_version": "1.17.1", "serial": 44, "lineage": "08978487-a0e2-dde8-16d9-a0cb8b286d63" จำนวน Resource 12 รายการ
	- โดยเมื่อเทียบกับโค้ดที่เราเขียนเองแค่ไม่กี่บล็อก จำนวนใน State มีมากกว่าเยอะมากเพราะโมดูล module.vpc ที่ดึงมาจาก Registry เป็นตัวสร้าง Resource ย่อยๆ ด้านเครือข่ายให้เราทั้งหมด

Checkpoint 7: Locate your admin_password output in the state file. It is declared sensitive = true, so Terraform hides it in CLI output. Is it encrypted in the state file? Is it obfuscated in any way?
	- ไม่ได้ถูกเข้ารหัสและไม่ได้ถูกปกปิดใดๆ เลย โดยรหัสผ่านใน admin_password.value ถูกจัดเก็บเป็นข้อความธรรมดาที่เปิดอ่านได้โดยตรงในไฟล์ terraform.tfstate เพราะ sensitive = true มีผลแค่การซ่อนข้อความบนหน้าจอ Terminal ตอนรัน plan/apply/output เท่านั้น

Checkpoint 8: For each pitfall you chose, submit: the error output, a one-paragraph diagnosis, and the corrected configuration.
	- Pitfall A ได้ผล Error Output: Error: Cycle: aws_security_group.db, aws_security_group.app โดยเกิดจากการอ้างอิงวนลูปเป็นวงกลม ซึ่งขัดกับหลักการ Directed Acyclic Graph (DAG) ของ Terraform ที่ห้ามมีวงจรปิด เมื่อเราเขียนบล็อก ingress ฝังไว้ข้างใน aws_security_group โดยตรง ทำให้ aws_security_group.app ต้องรอให้ db สร้างเสร็จก่อนเพื่อดึง ID มาใช้ ในขณะที่ aws_security_group.db ก็ต้องรอให้ app สร้างเสร็จก่อนเพื่อดึง ID มาใช้เหมือนกัน Terraform จึงไม่สามารถจัดลำดับได้ว่าต้องสร้างตัวไหนก่อน การแยกกฎออกมาเป็น aws_vpc_security_group_ingress_rule จะช่วยแก้ปัญหานี้ได้ เพราะทำให้ Terraform สามารถสร้างตัว Security Group เปล่าๆ ทั้งสองตัวให้เสร็จสิ้นก่อนในขั้นตอนแรก แล้วจึงสร้างกฎ Ingress ผูกเข้าหากันในภายหลัง ทำให้ทิศทางของกราฟพุ่งไปทางเดียวโดยไม่วนลูป
	- Pitfall B ได้ผล ~ tags = { ~ "LastPlanned" = "..." -> (known after apply) } บนทุก Resource แม้จะไม่ได้แก้ไขโค้ดใดๆ โดยในทุกครั้งที่รัน plan ตัว Terraform จะนำค่าเก่าที่บันทึกอยู่ในไฟล์ terraform.tfstate มาเปรียบเทียบกับค่าใหม่ที่ประเมินได้จากโค้ด Configuration สาเหตุที่ค่าทั้งสองไม่เคยตรงกันเลยเป็นเพราะฟังก์ชัน timestamp() แตกต่างจากฟังก์ชันอื่นๆ ที่ใช้ใน Lab 3 ซึ่งเป็น Pure functions ที่คืนค่าเดิมเสมอเมื่อได้ Input เดิม แต่ timestamp() เป็นฟังก์ชันที่อ่านเวลาปัจจุบันของระบบใหม่ทุกครั้งที่รัน ทำให้ค่าที่คำนวณได้ตอน Plan ใหม่กว่าเวลาเดิมใน State เสมอ และเนื่องจากแท็กนี้อยู่ใน local.common_tags จึงทำให้ทุก Resource ที่ดึงแท็กนี้ไปใช้แสดงสถานะต้องอัปเดตใหม่ทุกครั้ง


Lab Report & Checkpoints Pictures (Google Docs): https://docs.google.com/document/d/1mCGgyQmoUGoMq13fedEhnpDl1yXTsZKcCSowlbGjZsU/edit?tab=t.jzn78u3mo92