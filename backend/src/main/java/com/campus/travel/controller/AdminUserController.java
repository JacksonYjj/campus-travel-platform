package com.campus.travel.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.campus.travel.mapper.UserAccountMapper;
import com.campus.travel.entity.UserAccount;

@RestController
@RequestMapping("/api/admin/users")
public class AdminUserController {

    @Autowired
    private UserAccountMapper userAccountMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllUsers() {
        List<UserAccount> users = userAccountMapper.findAll();
        List<Map<String, Object>> result = users.stream().map(u -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", u.getId());
            map.put("username", u.getUsername());
            map.put("realName", u.getRealName());
            map.put("phone", u.getPhone());
            map.put("creditScore", u.getCreditScore() != null ? u.getCreditScore() : 100);
            
            // Mock role logic consistent with dummy logic
            String username = u.getUsername() != null ? u.getUsername() : "";
            if (username.startsWith("admin")) {
                map.put("role", "ADMIN");
            } else if (username.startsWith("driver")) {
                map.put("role", "DRIVER");
            } else if (username.startsWith("organizer")) {
                map.put("role", "ORGANIZER");
            } else {
                map.put("role", "STUDENT");
            }
            
            // Front-end expects "active" or "banned"
            String dbStatus = u.getAccountStatus();
            if ("disabled".equals(dbStatus) || "frozen".equals(dbStatus) || "banned".equals(dbStatus)) {
                map.put("status", "banned");
            } else {
                map.put("status", "active");
            }
            
            return map;
        }).collect(Collectors.toList());
        
        Map<String, Object> response = new HashMap<>();
        response.put("data", result);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, String>> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String newStatusStr = body.get("status");
        String dbStatus = "active".equals(newStatusStr) ? "active" : "disabled";
        
        userAccountMapper.updateStatus(id, dbStatus);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "success");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/reset-password")
    public ResponseEntity<Map<String, String>> resetPassword(@PathVariable Long id) {
        String newHash = passwordEncoder.encode("123456");
        userAccountMapper.updatePassword(id, newHash);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "success");
        return ResponseEntity.ok(response);
    }
}