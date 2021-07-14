// @dart=2.9
import 'dart:io';

import 'package:git_hooks/git_hooks.dart';
import 'package:process_run/shell.dart';

void main(List<String> arguments) {
  final Map<Git, UserBackFun> params = {
    Git.commitMsg: commitMsg,
    Git.preCommit: preCommit
  };
  GitHooks.call(arguments, params);
}

Future<bool> commitMsg() async {
  final String commitMsg = Utils.getCommitEditMsg();
  // 规范提交日志
  if (commitMsg.startsWith('Feat:') || //新功能
      commitMsg.startsWith('Fix:') || //错误修复
      commitMsg.startsWith('Refactor:') || //代码重构
      commitMsg.startsWith('Style:') || //格式、分号缺失等，代码无变动
      commitMsg.startsWith('Docs:') || //文档修改
      commitMsg.startsWith('Test:') || // 测试添加、测试重构等
      commitMsg.startsWith('Chore:') || // 构建任务更新、程序包管理器配置等，生产代码无变动
      commitMsg.startsWith('Merge')) {
    return true;
  } else {
    print('请在提交文案添加前缀');
    return false;
  }
}

/// 在 git commit 的完成前执行
Future<bool> preCommit() async {
  final Shell shell = Shell();
  // 提交文案
  final String commitMsg = Utils.getCommitEditMsg();

  // 获取当前分支名
  final List<ProcessResult> branchRes =
      await shell.run('git branch --show-current');
  final String branch = branchRes.first.stdout;

  bool increaseBuildNum = false;

  // 自动增加build号时机
  if (commitMsg.startsWith('Merge')) {
    increaseBuildNum = false;
  } else {
    if (branch.startsWith('v')) {
      increaseBuildNum = true;
    } else {
      if (commitMsg.startsWith('Feat') ||
          commitMsg.startsWith('Fix') ||
          commitMsg.startsWith('Refactor')) {
        increaseBuildNum = true;
      } else {
        increaseBuildNum = false;
      }
    }
  }
  if (increaseBuildNum) {
    try {
      /// 执行增加build 号
      final List<ProcessResult> result =
          await shell.run('sh increase_build_num.sh');
      print('$result');
      return true;
    } catch (e) {
      return false;
    }
  } else {
    return true;
  }
}
