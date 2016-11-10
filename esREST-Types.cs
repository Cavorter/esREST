namespace esREST {
	public enum ClusterPrivilege {
		all,
		monitor,
		manage,
		manage_security,
		manage_index_templates,
		transport_client
	
	}
	
	public enum IndexPrivilege {
		all,
		manage,
		monitor,
		view_index_metadata,
		read,
		index,
		create,
		delete,
		write,
		delete_index,
		create_index
	}

	public class IndexPrivilegeGroup {
		public string[] Index { get; set; }
		public string[] Privilege { get; set; }
		public string[] Field { get; set; }

		public IndexPrivilegeGroup() {
			Index = null;
			Privilege = null;
			Field = null;
		}
	}
	
	public class Role {
		public string Name { get; set; }
		public string[] ClusterPrivilege { get; set; }
		public IndexPrivilegeGroup[] IndexPrivilegeGroup { get; set; }
		public string[] RunAs { get; set; }
		
		public Role () {
			Name = null;
			ClusterPrivilege = null;
			IndexPrivilegeGroup = null;
			RunAs = null;
		}
	}
}