variable "cidr_block"{
    type = string
}

variable "project"{
    type = string
}

variable "environment"{
    type = string
}

variable "public_cidrs"{
    type = list
}

variable "private_cidrs"{
    type = list
}

variable "database_cidrs"{
    type = list
}

variable "is_peering_required" {
    type = bool
}