"""
MediaPipe Hands WebSocket 服务器
运行: pip install mediapipe opencv-python websockets numpy
      python hand_server.py

Flutter 端发送: 原始 NV21 字节 + 4字节小端宽度 + 4字节小端高度（共 w*h*3/2 + 8 字节）
服务器返回: JSON {"landmarks": [[x,y,z], ...21点...]} 或 {"landmarks": []}
"""

import asyncio
import json
import struct
import cv2
import numpy as np
import mediapipe as mp
import websockets

mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,
    min_detection_confidence=0.6,
    min_tracking_confidence=0.5,
)

async def handle(websocket):
    print("客户端已连接")
    try:
        async for message in websocket:
            data = bytes(message)
            if len(data) < 8:
                await websocket.send(json.dumps({"landmarks": []}))
                continue

            # 末尾 8 字节：宽度(4) + 高度(4)，小端
            w = struct.unpack_from('<I', data, len(data) - 8)[0]
            h = struct.unpack_from('<I', data, len(data) - 4)[0]
            nv21 = data[:len(data) - 8]

            expected = w * h * 3 // 2
            if len(nv21) != expected:
                await websocket.send(json.dumps({"landmarks": []}))
                continue

            # NV21 → BGR → RGB
            yuv = np.frombuffer(nv21, dtype=np.uint8).reshape((h * 3 // 2, w))
            bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_NV21)
            rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)

            result = hands.process(rgb)
            if result.multi_hand_landmarks:
                lms = [[lm.x, lm.y, lm.z] for lm in result.multi_hand_landmarks[0].landmark]
                await websocket.send(json.dumps({"landmarks": lms}))
            else:
                await websocket.send(json.dumps({"landmarks": []}))
    except websockets.exceptions.ConnectionClosed:
        print("客户端断开")

async def main():
    print("MediaPipe Hands 服务器启动，监听 ws://0.0.0.0:8765")
    async with websockets.serve(handle, "0.0.0.0", 8765):
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
