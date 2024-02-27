import 'package:apidash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apidash/providers/providers.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash/consts.dart';

class EditorPaneRequestURLCard extends StatelessWidget {
  const EditorPaneRequestURLCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        borderRadius: kBorderRadius12,
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
        child: Row(
          children: [
            DropdownButtonHTTPMethod(),
            kHSpacer20,
            Expanded(
              child: URLTextField(),
            ),
            kHSpacer20,
            SizedBox(
              height: 36,
              child: SendButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownButtonHTTPMethod extends ConsumerWidget {
  const DropdownButtonHTTPMethod({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref
        .watch(selectedRequestModelProvider.select((value) => value?.method));
    return DropdownButtonHttpMethod(
      method: method,
      onChanged: (HTTPVerb? value) {
        final selectedId = ref.read(selectedRequestModelProvider)!.id;
        ref
            .read(collectionStateNotifierProvider.notifier)
            .update(selectedId, method: value);
      },
    );
  }
}

class URLTextField extends ConsumerWidget {
  const URLTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedIdStateProvider);
    return URLField(
      selectedId: selectedId!,
      requestParams: ref.watch(selectedRequestModelProvider)?.requestParams,
      initialValue: ref.watch(selectedRequestModelProvider)?.url,
      onChanged: (value) {
        final uri = Uri.parse(value);
        // Update requestParams if query parameters exist
        if (uri.queryParameters.isNotEmpty) {
          final updatedParams = uri.queryParametersAll.entries
              .map((entry) => NameValueModel(
                  name: entry.key,
                  value: entry.value.isNotEmpty ? entry.value.join(',') : ""))
              .toList();

          ref.read(collectionStateNotifierProvider.notifier).update(selectedId,
              url: value,
              requestParams: updatedParams,
              isParamEnabledList:
                  List.filled(updatedParams.length, true, growable: true));
        } else {
          ref.read(collectionStateNotifierProvider.notifier).update(selectedId,
              url: value,
              requestParams: [kNameValueEmptyModel],
              isParamEnabledList: List.filled(1, true, growable: true));
        }
      },
    );
  }
}

class SendButton extends ConsumerWidget {
  const SendButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedIdStateProvider);
    final sentRequestId = ref.watch(sentRequestIdStateProvider);
    return SendRequestButton(
      selectedId: selectedId,
      sentRequestId: sentRequestId,
      onTap: () {
        ref
            .read(collectionStateNotifierProvider.notifier)
            .sendRequest(selectedId!);
      },
    );
  }
}
