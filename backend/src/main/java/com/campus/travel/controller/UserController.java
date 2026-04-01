package com.campus.travel.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.beans.factory.annotation.Autowired;
import com.campus.travel.mapper.UserAccountMapper;
import com.campus.travel.entity.UserAccount;
import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserAccountMapper userAccountMapper;

    private String getUsernameFromRequest(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer simulated_jwt_token_for_")) {
            return authHeader.substring("Bearer simulated_jwt_token_for_".length());
        }
        return null;
    }

    @GetMapping("/user/profile")
    public ResponseEntity<Map<String, Object>> getProfile(HttpServletRequest request) {
        Map<String, Object> profile = new HashMap<>();
        String username = getUsernameFromRequest(request);

        if (username == null) {
             return ResponseEntity.status(401).build();
        }

        UserAccount user = userAccountMapper.findByUsername(username);
        
        if (user != null) {
            profile.put("username", user.getUsername());
            profile.put("realName", user.getRealName());
            
            // Temporary role logic based on username
            if (user.getUsername() != null && user.getUsername().startsWith("admin")) {
                profile.put("role", "ADMIN");
            } else {
                profile.put("role", "STUDENT");
            }
            
            profile.put("phone", user.getPhone());
            profile.put("studentId", user.getStudentNo());
            profile.put("creditScore", user.getCreditScore() != null ? user.getCreditScore() : 100);
            profile.put("completedTrips", 0); // Mock trips
            profile.put("signature", "This person is very lazy...");
        } else {
            // Mock fallback if user doesn't exist in DB but somehow has a token
            profile.put("username", username);
            profile.put("realName", "Unknown");
            profile.put("role", "STUDENT");
            profile.put("phone", "");
            profile.put("creditScore", 100);
            profile.put("completedTrips", 0);
        }

        return ResponseEntity.ok(profile);
    }

    @PostMapping("/user/profile")
    public ResponseEntity<Map<String, String>> updateProfile(@RequestBody Map<String, String> body, HttpServletRequest request) {
        String username = getUsernameFromRequest(request);

        if (username == null) {
             return ResponseEntity.status(401).build();
        }

        UserAccount user = userAccountMapper.findByUsername(username);
        if (user != null) {
            if (body.containsKey("realName")) user.setRealName(body.get("realName"));
            if (body.containsKey("phone")) user.setPhone(body.get("phone"));
            if (body.containsKey("studentId")) user.setStudentNo(body.get("studentId"));
            // We ignore signature for now because the DB entity doesn't have it, but we return success.
            userAccountMapper.updateProfile(user);
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "success");
        return ResponseEntity.ok(response);
    }
}