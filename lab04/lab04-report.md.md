<Question>
Question 1: What is the difference between try() and can()? When would you reach for each?
Ans: try() จะประมวลผลนิพจน์และคืนค่าจริงหรือค่าสำรองออกมาหากเกิด Error จึงเหมาะใช้ตอนกำหนดค่าเริ่มต้นให้กับข้อมูลที่อาจไม่มีอยู่จริง ส่วน can() จะทดสอบว่านิพจน์ทำงานได้โดยไม่เกิด Error หรือไม่ แล้วคืนค่าเป็น Boolean จึงเหมาะใช้ในบล็อก validation หรือเงื่อนไข if

Question 2: Which instance does Terraform destroy? Now imagine you had 3 instances and wanted to remove the middle one. What would count do? This is the classic count pitfall.
Ans: เมื่อลดจำนวน Instance จาก 2 เหลือ 1 Terraform จะทำลายตัวสุดท้ายคือ aws_instance.web[1] ทิ้ง และหากมี 3 ตัว ([0], [1], [2]) แล้วต้องการลบตัวกลางออก การใช้ count ที่อ้างอิงตามลำดับ Index จะทำให้ตัวที่ [2] เลื่อนลำดับลงมาเป็น [1] แทน ส่งผลให้ Terraform ต้องอัปเดตหรือทำลายแล้วสร้างใหม่ในลำดับถัดไปทั้งหมด

Question 3: Removing api from the for_each map destroys only the api instance. Explain in one sentence why for_each is safer than count for non-identical resources.
Ans: for_each ปลอดภัยกว่าเพราะอ้างอิงทรัพยากรแต่ละตัวด้วย Stable key แทน Index ดังนั้นการเพิ่มหรือลบทรัพยากรตัวใดตัวหนึ่งจึงส่งผลเฉพาะตัวนั้นโดยไม่ทำให้ลำดับของตัวอื่นเลื่อนจนถูกทำลายและสร้างใหม่โดยไม่ได้ตั้งใจ

Question 4: Rewrite [for k, v in var.servers : k if v.role == "backend"] using only functions (keys, lookup, etc.). Which version is more readable?
Ans: ถ้าเปลี่ยนมาใช้เฉพาะฟังก์ชันจะสามารถเขียนได้เป็น [lookup(zipmap(values(var.servers)[*].role, keys(var.servers)), "backend", "")] ซึ่งเมื่อเทียบกันแล้ว การเขียนด้วย [for k, v in var.servers : k if v.role == "backend"] จะอ่านเข้าใจง่ายกว่า เพราะมองเห็นเงื่อนไข if ที่ใช้กรองข้อมูลได้ตรงๆ ในบรรทัดเดียวโดยไม่ต้องซ้อนฟังก์ชันหลายชั้น

Question 5: In the dynamic "ingress" block, what do ingress.key and ingress.value refer to? What would they be if for_each were a map instead of a list?
Ans: เมื่อวนลูปจาก List (var.ingress_rules) ค่า ingress.key จะหมายถึง ตัวเลขลำดับ Index ของรายการนั้น และ ingress.value จะหมายถึง ข้อมูล Object ของกฎแต่ละข้อที่มี port, protocol, cidr_blocks แต่ถ้าหาก for_each เป็น Map ค่า ingress.key จะกลายเป็น Map key และ ingress.value ก็จะเป็น Map value ที่ผูกอยู่กับคีย์นั้นๆ


<Checkpoint>
Checkpoint 1: Record the output of every expression above in your report.
	- Step 1.1:
		- 5 + 3 * 2  => 11
		- 10 % 3 => 1
		- "a" == "a" && 1 < 2 => true
		- 3 > 5 ? "big" : "small" => "small"
		- var.environment == "prod" ? "t3.large" : "t3.micro" => "t3.micro"
	- Step 1.2:
		- upper("terraform") => "TERRAFORM"
		- join("-", ["ipa", "lab03", "web"]) => "ipa-lab03-web"
		- split(",", "a,b,c") => tolist(["a", "b", "c"])
		- format("%s-%03d", "web", 7) => "web-007"
		- substr("hello world", 0, 5) => "hello"
		- trimspace("  padded  ") => "padded"
		- replace("my_project_name", "_", "-") => "my-project-name"
	- Step 1.3:
		- length(["a", "b", "c"]) => 3
		- merge({a = 1}, {b = 2}) => {"a" = 1, "b" = 2}
		- keys({name = "kmitl", age = 60}) => tolist(["age", "name"])
		- values({name = "kmitl", age = 60}) => tolist([60, "kmitl"])
		- lookup({a = 1, b = 2}, "c", "default") => "default"
		- contains(["dev", "prod"], "dev") => true
		- toset(["a", "b", "a"]) => toset(["a", "b"])
		- flatten([[1, 2], [3, 4]]) => [1, 2, 3, 4]
		- zipmap(["a", "b"], [1, 2]) => {"a" = 1, "b" = 2}
	- Step 1.4:
		- regex("[0-9]+", "instance-42-web") => "42"
		- regexall("[a-z]+", "ab12cd34ef") => tolist(["ab", "cd", "ef"])
		- can(regex("^t[23]\\.", "t3.micro")) => true
		- can(regex("^t[23]\\.", "m5.large")) => false
	- Step 1.5:
		- tostring(42) => "42"
		- tonumber("3.14") => 3.14
		- tolist(toset(["b", "a"])) => tolist(["a", "b"])
		- try(tonumber("not-a-number"), 0) => 0
		- can(tonumber("not-a-number")) => false

Checkpoint 2: Show both results side by side in your report.
	- เมื่อรัน terraform console จะได้เป็นดังนี้
		- local.effective_instance_type => "t3.micro"
		- local.is_production => false
	- เมื่อรัน terraform console -var="environment=prod" จะได้เป็นดังนี้
		- local.effective_instance_type => "t3.medium"

Checkpoint 3: Compare the resource addresses: aws_instance.web[0] versus aws_instance.server["web"].
	- aws_instance.web[0] จะอ้างอิงทรัพยากรด้วย Numeric index ซึ่งลำดับอาจเลื่อนและเปลี่ยนไปได้เมื่อมีการเพิ่มหรือลบสมาชิก
	- aws_instance.server["web"] จะอ้างอิงทรัพยากรด้วย Stable string key ทำให้ระบุตัวตนของแต่ละ Instance ได้อย่างแม่นยำและเป็นอิสระต่อกัน

Checkpoint 4: Show the plan diff proving the third ingress rule appeared.
	  # module.web_server.aws_security_group.web must be replaced
-/+ resource "aws_security_group" "web" {
      ~ arn                    = "arn:aws:ec2:us-east-1:983631791995:security-group/sg-0ae13587442e790cc" -> (known after apply)
      ~ description            = "Allow HTTP inbound" -> "Dynamically generated ingress rules" # forces replacement
      ~ id                     = "sg-0ae13587442e790cc" -> (known after apply)
      ~ ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - from_port        = 80
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 80
                # (1 unchanged attribute hidden)
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Application port added by the caller"
              + from_port        = 8080
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8080
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTP"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "10.0.0.0/8",
                ]
              + description      = "SSH from the office network"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
	
Checkpoint 5: Show the dev and prod plans side by side and point out all three differences.
	- ใน dev จะมีกฎ Ingress เปิดพอร์ต 22 ให้ ["10.0.0.0/8"] แต่ใน prod ค่า local.ssh_cidrs จะกลายเป็น List ว่าง ทำให้เงื่อนไข if length(rule.cidr_blocks) > 0 กรองกฎ SSH ทิ้งไป เหลือแค่พอร์ต 80 และ 8080
	- ใน dev เซิร์ฟเวอร์ทั้งสองตัว (web และ api) ใช้ instance_type = "t3.micro" แต่ใน prod ทั้งคู่จะถูกปรับขนาดขึ้นเป็น "t3.medium" ตามค่า local.effective_instance_type
	- ใน dev พื้นที่เก็บข้อมูล root_block_device จะมีขนาด volume_size = 8 GB แต่ใน prod จะขยายขนาดเป็น volume_size = 30 GB และบังคับเข้ารหัส encrypted = true เสมอ


Lab Report & Checkpoints Pictures (Google Docs): https://docs.google.com/document/d/1mCGgyQmoUGoMq13fedEhnpDl1yXTsZKcCSowlbGjZsU/edit?tab=t.y2ksqctukw77