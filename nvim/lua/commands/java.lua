local M = {}

local function detect_package()
	local current_path = vim.fn.expand("%:p:h")

	local package_path = current_path:match(".*/src/main/java/(.*)")

	if package_path and package_path ~= "" then
		return package_path:gsub("/", ".")
	end

	local java_path = current_path:match(".*/java/(.*)")
	if java_path and java_path ~= "" then
		return java_path:gsub("/", ".")
	end

	local com_path = current_path:match(".*/com/(.*)")
	if com_path and com_path ~= "" then
		return "com." .. com_path:gsub("/", ".")
	end

	local org_path = current_path:match(".*/org/(.*)")
	if org_path and org_path ~= "" then
		return "org." .. org_path:gsub("/", ".")
	end

	return "com.example"
end

local templates = {
	class = function(class_name, package)
		return string.format(
			[[package %s;

/**
 * %s
 * 
 * @author %s
 * @version 1.0
 */
public class %s {
    
    public %s() {
        
    }
    
}]],
			package,
			class_name,
			os.getenv("USER") or "Developer",
			class_name,
			class_name
		)
	end,

	interface = function(interface_name, package)
		return string.format(
			[[package %s;

/**
 * %s
 * 
 * @author %s
 * @version 1.0
 */
public interface %s {
    
}]],
			package,
			interface_name,
			os.getenv("USER") or "Developer",
			interface_name
		)
	end,

	enum = function(enum_name, package)
		return string.format(
			[[package %s;

/**
 * %s
 * 
 * @author %s
 * @version 1.0
 */
public enum %s {
    
}]],
			package,
			enum_name,
			os.getenv("USER") or "Developer",
			enum_name
		)
	end,

	record = function(record_name, package)
		return string.format(
			[[package %s;

/**
 * %s
 * 
 * @author %s
 * @version 1.0
 */
public record %s() {
    
}]],
			package,
			record_name,
			os.getenv("USER") or "Developer",
			record_name
		)
	end,

	controller = function(controller_name, package)
		local base_name = controller_name:gsub("Controller$", "")
		return string.format(
			[[package %s;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * %s REST Controller
 * 
 * @author %s
 * @version 1.0
 */
@RestController
@RequestMapping("/api/%s")
@CrossOrigin(origins = "*")
public class %s {
    
    @Autowired
    private %sService %sService;
    
    @GetMapping
    public ResponseEntity<String> hello() {
        return ResponseEntity.ok("Hello from %s!");
    }
    
}]],
			package,
			base_name,
			os.getenv("USER") or "Developer",
			base_name:lower(),
			controller_name,
			base_name,
			base_name:lower(),
			controller_name
		)
	end,

	service = function(service_name, package)
		local base_name = service_name:gsub("Service$", "")
		return string.format(
			[[package %s;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * %s Service
 * 
 * @author %s
 * @version 1.0
 */
@Service
public class %s {
    
    @Autowired
    private %sRepository %sRepository;
    
    // TODO: Implement service methods
    
}]],
			package,
			base_name,
			os.getenv("USER") or "Developer",
			service_name,
			base_name,
			base_name:lower()
		)
	end,

	repository = function(repository_name, package)
		local base_name = repository_name:gsub("Repository$", "")
		return string.format(
			[[package %s;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * %s Repository
 * 
 * @author %s
 * @version 1.0
 */
@Repository
public interface %s extends JpaRepository<%s, Long> {
    
    // TODO: Add custom query methods
    
}]],
			package,
			base_name,
			os.getenv("USER") or "Developer",
			repository_name,
			base_name
		)
	end,

	entity = function(entity_name, package)
		return string.format(
			[[package %s;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * %s Entity
 * 
 * @author %s
 * @version 1.0
 */
@Entity
@Table(name = "%s")
public class %s {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public %s() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
}]],
			package,
			entity_name,
			os.getenv("USER") or "Developer",
			entity_name:lower(),
			entity_name,
			entity_name
		)
	end,

	dto = function(dto_name, package)
		return string.format(
			[[package %s;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * %s DTO
 * 
 * @author %s
 * @version 1.0
 */
public class %s {
    
    @JsonProperty("id")
    private Long id;
    
    public %s() {}
    
    public %s(Long id) {
        this.id = id;
    }
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
}]],
			package,
			dto_name,
			os.getenv("USER") or "Developer",
			dto_name,
			dto_name,
			dto_name
		)
	end,

	test = function(test_name, package)
		local base_name = test_name:gsub("Test$", "")
		return string.format(
			[[package %s;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.springframework.boot.test.context.SpringBootTest;
import static org.junit.jupiter.api.Assertions.*;

/**
 * %s Test
 * 
 * @author %s
 * @version 1.0
 */
@SpringBootTest
@DisplayName("%s Tests")
class %s {
    
    @BeforeEach
    void setUp() {
        // Setup test data
    }
    
    @Test
    @DisplayName("Should test basic functionality")
    void shouldTestBasicFunctionality() {
        // Given
        
        // When
        
        // Then
        assertTrue(true);
    }
    
}]],
			package,
			base_name,
			os.getenv("USER") or "Developer",
			base_name,
			test_name
		)
	end,
}

function M.create_java_file(file_type, file_name, custom_package)
	if not templates[file_type] then
		print("Invalid type! Available types: " .. table.concat(vim.tbl_keys(templates), ", "))
		return
	end

	local package = custom_package or detect_package()

	local content = templates[file_type](file_name, package)

	local file_path = file_name .. ".java"

	local file = io.open(file_path, "w")
	if file then
		file:write(content)
		file:close()

		vim.cmd("edit " .. file_path)

		print(string.format("✅ File %s created successfuly! Package: %s", file_path, package))
	else
		print("❌ Error creating file!")
	end
end

function M.create_java_interactive()
	local types = vim.tbl_keys(templates)
	table.sort(types)

	vim.ui.select(types, {
		prompt = "Select Java file type:",
		format_item = function(item)
			return item:upper()
				.. " - "
				.. (
					item == "dto" and "Data Transfer Object"
					or item == "entity" and "JPA Entity"
					or item == "test" and "JUnit Test"
					or item:gsub("^%l", string.upper)
				)
		end,
	}, function(selected_type)
		if not selected_type then
			return
		end

		vim.ui.input({
			prompt = string.format("%s name: ", selected_type),
			default = "",
		}, function(file_name)
			if not file_name or file_name == "" then
				return
			end

			vim.ui.input({
				prompt = "Package (keep empty to auto-detect): ",
				default = detect_package(),
			}, function(custom_package)
				if custom_package == "" then
					custom_package = nil
				end
				M.create_java_file(selected_type, file_name, custom_package)
			end)
		end)
	end)
end

return M
