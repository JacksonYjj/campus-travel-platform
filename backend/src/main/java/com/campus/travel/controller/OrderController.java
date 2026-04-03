package com.campus.travel.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import com.campus.travel.mapper.OrderMapper;
import com.campus.travel.mapper.UserAccountMapper;
import com.campus.travel.entity.UserAccount;
import jakarta.servlet.http.HttpServletRequest;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class OrderController {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private UserAccountMapper userAccountMapper;

    private Long getUserIdFromRequest(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer simulated_jwt_token_for_")) {
            String username = authHeader.substring("Bearer simulated_jwt_token_for_".length());
            UserAccount user = userAccountMapper.findByUsername(username);
            return user != null ? user.getId() : null;
        }
        return null;
    }

    @GetMapping("/orders/list")
    public ResponseEntity<List<Map<String, Object>>> getOrders(
            @RequestParam(required = false, defaultValue = "carpool") String type,
            HttpServletRequest request) {
        
        Long userId = getUserIdFromRequest(request);
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        List<Map<String, Object>> orders;
        if ("carpool".equals(type)) {
            orders = orderMapper.findCarpoolOrdersByUserId(userId);
        } else {
            orders = orderMapper.findGroupOrdersByUserId(userId);
        }

        // Format date and format status for frontend consistency
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        for (Map<String, Object> order : orders) {
            if (order.get("createTime") instanceof LocalDateTime) {
                order.put("createTime", ((LocalDateTime) order.get("createTime")).format(formatter));
            }
            if ("PENDING_CONFIRM".equals(order.get("status")) || "PENDING_PAY".equals(order.get("status"))) {
                order.put("status", "PENDING");
            }
        }

        return ResponseEntity.ok(orders);
    }

    @PostMapping("/orders/{id}/cancel")
    public ResponseEntity<Map<String, String>> cancelOrder(
            @PathVariable Long id,
            @RequestParam(required = false, defaultValue = "carpool") String type,
            HttpServletRequest request) {
        
        Long userId = getUserIdFromRequest(request);
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        int updated;
        if ("carpool".equals(type)) {
            updated = orderMapper.cancelCarpoolOrder(id, userId);
        } else {
            updated = orderMapper.cancelGroupOrder(id, userId);
        }

        if (updated == 0) {
            return ResponseEntity.badRequest().body(Map.of("message", "取消失败，订单不存在或不属于您"));
        }

        return ResponseEntity.ok(Map.of("message", "success"));
    }

    @GetMapping("/orders/{id}/details")
    public ResponseEntity<Map<String, Object>> getOrderDetails(
            @PathVariable Long id,
            @RequestParam(required = false, defaultValue = "carpool") String type,
            HttpServletRequest request) {
        
        Long userId = getUserIdFromRequest(request);
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        Map<String, Object> details;
        if ("carpool".equals(type)) {
            details = orderMapper.getCarpoolOrderDetails(id, userId);
        } else {
            details = orderMapper.getGroupOrderDetails(id, userId);
        }

        if (details == null) {
            return ResponseEntity.notFound().build();
        }

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        if (details.get("createTime") instanceof LocalDateTime) {
            details.put("createTime", ((LocalDateTime) details.get("createTime")).format(formatter));
        }

        return ResponseEntity.ok(details);
    }
}
