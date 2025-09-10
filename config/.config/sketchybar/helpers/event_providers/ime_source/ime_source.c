#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Carbon/Carbon.h>
#include "../sketchybar.h"

// why: TIS APIからType/Mode/IDを取り、判定キーを安定化（モード変更も検知）
static void get_current_source_state(char* type_buf, size_t type_len,
                                     char* mode_buf, size_t mode_len,
                                     char* id_buf, size_t id_len) {
  type_buf[0] = '\0';
  mode_buf[0] = '\0';
  id_buf[0] = '\0';

  TISInputSourceRef src = TISCopyCurrentKeyboardInputSource();
  if (!src) return;

  CFStringRef type = TISGetInputSourceProperty(src, kTISPropertyInputSourceType);
  if (type) CFStringGetCString(type, type_buf, type_len, kCFStringEncodingUTF8);

  CFStringRef mode = TISGetInputSourceProperty(src, kTISPropertyInputModeID);
  if (mode) CFStringGetCString(mode, mode_buf, mode_len, kCFStringEncodingUTF8);

  CFStringRef id = TISGetInputSourceProperty(src, kTISPropertyInputSourceID);
  if (id) CFStringGetCString(id, id_buf, id_len, kCFStringEncodingUTF8);

  // why: TISGet... は所有権を移譲しないためプロパティ(CFStringRef)は解放不要
  CFRelease(src);
}

static const char* map_mode_from_state(const char* type, const char* mode, const char* id) {
  // 英語（物理レイアウト）
  if ((type && strstr(type, "KeyboardLayout")) || (id && strstr(id, ".keylayout."))) return "A";
  // 日本語IME（Kotoeri等）
  if ((type && strstr(type, "KeyboardInput")) || (id && strstr(id, ".inputmethod.")) || (mode && *mode)) return "あ";
  return "-";
}

static const char* g_event_name = NULL;

static void notify_cb(CFNotificationCenterRef center,
                      void *observer,
                      CFStringRef name,
                      const void *object,
                      CFDictionaryRef userInfo) {
  (void)center; (void)observer; (void)name; (void)object; (void)userInfo;
  char type[128], mode_id[256], id[256];
  get_current_source_state(type, sizeof(type), mode_id, sizeof(mode_id), id, sizeof(id));
  const char* mode = map_mode_from_state(type, mode_id, id);
  // why: 固定長バッファでのsnprintfは切り詰めの恐れがあるため動的確保に変更
  int trigger_len = snprintf(NULL, 0,
                             "--trigger '%s' mode='%s' id='%s' type='%s' input_mode='%s'",
                             g_event_name, mode, id, type, mode_id);
  if (trigger_len < 0) return;
  size_t alloc = (size_t)trigger_len + 1;
  char* trigger = (char*)malloc(alloc);
  if (!trigger) return;
  snprintf(trigger, alloc, "--trigger '%s' mode='%s' id='%s' type='%s' input_mode='%s'",
           g_event_name, mode, id, type, mode_id);
  sketchybar(trigger);
  free(trigger);
}

int main (int argc, char** argv) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s '<event-name>' [dummy-interval]""\n", argv[0]);
    exit(1);
  }

  g_event_name = argv[1];

  // sketchybarへイベントを登録
  char event_msg[256];
  snprintf(event_msg, sizeof(event_msg), "--add event '%s'", g_event_name);
  sketchybar(event_msg);

  // 初回即時トリガ
  notify_cb(NULL, NULL, NULL, NULL, NULL);

  // TISの入力ソース変更通知を購読（Distributed Notification）
  CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
  CFNotificationCenterAddObserver(center,
                                  NULL,
                                  notify_cb,
                                  CFSTR("com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"),
                                  NULL,
                                  CFNotificationSuspensionBehaviorDeliverImmediately);

  CFRunLoopRun();
  return 0;
}
