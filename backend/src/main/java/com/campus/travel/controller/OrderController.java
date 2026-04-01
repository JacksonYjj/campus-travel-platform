package com.campus.travel.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class OrderController {
    @GetMapping("/orders/list")
    public ResponseEntity<List<Map<String, Object>>> getOrders(@RequestParam(required = false, defaultValue = "carpool") String type) {
        List<Map<String, Object>> orders = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        if ("carpool".equals(type)) {
            Map<String, Object> order1 = new HashMap<>();
            order1.put("id", 1);
            order1.put("orderNo", "CP-20240401-001");
            order1.put("title", "拼车：东校区侧门 -> 高铁南站");
            order1.put("amount", "15.00");
            order1.put("status", "CONFIRMED");
            order1.put("createTime", LocalDateTime.now().minusDays(1).format(formatter));

            Map<String, Object> order2 = new HashMap<>();
            order2.put("id", 2);
            order2.put("orderNo", "CP-20240328-042");
            order2.put("title", "拼车：西区宿舍楼 -> 万达广场");
            order2.put("amount", "10.00");
            order2.put("status", "COMPLETED");
            order2.put("createTime", LocalDateTime.now().minusDays(4).format(formatter));
            
            orders.add(order1);
            orders.add(order2);
        } else {
            Map<String, Object> order3 = new HashMap<>();
            order3.put("id", 3);
            order3.put("orderNo", "GT-20240405-088");
            order3.put("title", "约团：周末清远漂流主题团");
            order3.put("amount", "120.00");
            order3.put("status", "PENDING");
            order3.put("createTime", LocalDateTime.now().minusHours(2).format(formatter));
            
            orders.add(order3);
        }

        return ResponseEntity.ok(orders);
    }
}
